package com.mkgroup.camera;

import static com.mkgroup.camera.command.EvCameraCmdConsts.EV_CAM_PORT;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.VDT_CAM_PORT;

import android.text.TextUtils;

import com.jakewharton.disklrucache.DiskLruCache;
import com.mkgroup.camera.message.bean.MountVersion;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbRequestQueue;
import com.mkgroup.camera.db.CameraItem;
import com.mkgroup.camera.db.LocalCameraDaoManager;
import com.mkgroup.camera.event.CameraConnectionEvent;
import com.mkgroup.camera.firmware.FirmwareManager;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.rest.NetworkService;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.FileUtils;
import com.mkgroup.camera.utils.RxBus;

import java.io.File;
import java.io.IOException;
import java.net.InetAddress;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;

public class VdtCameraManager {
    private static final String TAG = VdtCameraManager.class.getSimpleName();

    private static VdtCameraManager mSharedManager = new VdtCameraManager();

    private RxBus mRxBus;

    private DiskLruCache mDiskLruCache = null;

    public DiskLruCache getRawDataDiskLruCache() {
        return mDiskLruCache;
    }

    public BehaviorSubject<Optional<CameraWrapper>> currentCamera() {
        return currentCameraObservable;
    }

    private BehaviorSubject<Optional<CameraWrapper>> currentCameraObservable = BehaviorSubject.createDefault(Optional.empty());

    public static VdtCameraManager getManager() {
        return mSharedManager;
    }

    private VdtCameraManager() {
        mRxBus = RxBus.getDefault();
        initRawDataCache();
    }

    private void initRawDataCache() {
        try {
            File cacheDir = FileUtils.createDiskCacheFile(WaylensCamera.getInstance().getApplicationContext(), "rawData");
            if (!cacheDir.exists()) {
                cacheDir.mkdirs();
            }
            mDiskLruCache = DiskLruCache.open(cacheDir, 1, 1, 20 * 1024 * 1024);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private volatile FirmwareManager firmwareManager;

    public FirmwareManager getFirmwareManager() {
        if (firmwareManager == null) {
            synchronized (VdtCameraManager.class) {
                if (firmwareManager == null) {
                    Logger.t(TAG).d("current cellularNetwork: " + NetworkService.getCellularNetwork());
                    firmwareManager = new FirmwareManager();
                }
            }
        }
        return firmwareManager;
    }

    public CameraWrapper getCamera(String sn) {
        for (CameraWrapper camera : mConnectedCameras) {
            if (camera.getSerialNumber().equals(sn)) {
                return camera;
            }
        }
        return null;
    }

    // note: CameraManager is a global data,
    // we have to track each callback even they are installed by the same activity.


    // cameras: connected + connecting + wifi-ap
    private final List<CameraWrapper> mConnectedCameras = new CopyOnWriteArrayList<>();
    private final List<CameraWrapper> mConnectingCameras = new CopyOnWriteArrayList<>();

    private CameraWrapper mCurrentCamera;

    private List<CameraWrapper.ServiceInfo> mServiceList = new CopyOnWriteArrayList<>();

    public synchronized void connectCamera(final CameraWrapper.ServiceInfo serviceInfo, final String from) {
        boolean filter = false;
        for (CameraWrapper.ServiceInfo item : mServiceList) {
            if (serviceInfo.inetAddr.equals(item.inetAddr)
                    && (serviceInfo.port == item.port)) {
//                    && (serviceInfo.port == item.port || item.port == EV_CAM_PORT)) {
                filter = true;
                Logger.t(TAG).d("filter camera " + serviceInfo.inetAddr + " " + serviceInfo.port + " from: " + from);
                break;
            }
        }
        if (!filter) {
            Logger.t(TAG).d("find camera add " + serviceInfo.inetAddr + " " + serviceInfo.port);
            mServiceList.add(serviceInfo);
            connectCameraImpl(serviceInfo, from);
        }

//        ConnectivityManager mConnectivityManager = (ConnectivityManager) Hachi.getContext().getSystemService(Context.CONNECTIVITY_SERVICE);
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//            final NetworkRequest networkRequest = new NetworkRequest.Builder()
//                .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
//                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
//                .build();
//            mConnectivityManager.requestNetwork(networkRequest, new ConnectivityManager.NetworkCallback() {
//                @Override
//                public void onAvailable(Network network) {
//
//                }
//            });
//        } else {
//            connectCameraImpl(serviceInfo, from);
//        }
//        vdtCamera.startClient();
    }

    private void connectCameraImpl(CameraWrapper.ServiceInfo serviceInfo, String from) {
        if (cameraExistsIn(serviceInfo.inetAddr, serviceInfo.port, mConnectingCameras)) {
            Logger.t(TAG).e("already existed in connecting");
            return;
        }
        if (cameraExistsIn(serviceInfo.inetAddr, serviceInfo.port, mConnectedCameras)) {
            Logger.t(TAG).e("already existed in connected");
            return;
        }

        Logger.t(TAG).e("connect Camera  " + serviceInfo.inetAddr + " port: " + serviceInfo.port + " from " + from + "--" + serviceInfo.toString());

        CameraWrapper cameraWrapper;
        if (serviceInfo.isVdtCamera) {
            cameraWrapper = new VdtCamera(serviceInfo, connectionChangeListener);
        } else {
            cameraWrapper = new EvCamera(serviceInfo, connectionChangeListener);
        }

        cameraWrapper.linkForm = from;

        mConnectingCameras.add(cameraWrapper);
        Logger.t(TAG).e("current connected camera size: " + mConnectedCameras.size()
                + " connecting camera size: " + mConnectingCameras.size());

    }

    private boolean cameraExistsIn(InetAddress inetAddr, int port, List<CameraWrapper> list) {
        for (CameraWrapper c : list) {
            InetAddress address = c.getAddress();
            int cPort = c.getPort();
            Logger.t(TAG).d("cameraExistsIn: " + address.toString() + "--" + inetAddr.toString()
                    + " port: " + cPort + "--" + port);
            if (address.equals(inetAddr) && cPort == port)
                return true;
        }
        return false;
    }

    public List<CameraWrapper.ServiceInfo> getServiceList() {
        return mServiceList;
    }

    public List<CameraWrapper> getConnectingVdtCameras() {
        return mConnectingCameras;
    }

    public List<CameraWrapper> getConnectedCameras() {
        return mConnectedCameras;
    }


    public CameraWrapper findConnectedCamera(String ssid, String hostString) {
        return findCameraInList(ssid, hostString, mConnectedCameras);
    }


    private CameraWrapper findCameraInList(String ssid, String hostString, List<CameraWrapper> list) {
        for (CameraWrapper c : list) {
            if (c.idMatch(ssid, hostString))
                return c;
        }
        return null;
    }


    public boolean isConnected() {
        return getConnectedCameras().size() > 0;
    }


    public void setCurrentCamera(int position) {
        this.mCurrentCamera = mConnectedCameras.get(position);
    }


    public CameraWrapper getCurrentCamera() {
        return mCurrentCamera;
    }

    public VdbRequestQueue getCurrentVdbRequestQueue() {
        if (mCurrentCamera != null) {
            return mCurrentCamera.getRequestQueue();
        } else {
            mCurrentCamera = mConnectedCameras.isEmpty() ? null : mConnectedCameras.get(0);
            if (mCurrentCamera != null) {
                return mCurrentCamera.getRequestQueue();
            }
            return null;
        }
    }

    private boolean onCameraConnected(CameraWrapper camera) {

        Observable.just(camera)
                .observeOn(Schedulers.io())
                .delay(3000, TimeUnit.MILLISECONDS)
                .subscribe(this::updateLocalCameraInfo);

        for (int i = 0; i < mConnectingCameras.size(); i++) {
            CameraWrapper oneCamera = mConnectingCameras.get(i);
            if (oneCamera == camera) {
                mConnectingCameras.remove(i);

                boolean existsIn = cameraExistsIn(camera.getAddress(), camera.getPort(), mConnectedCameras);
                if (!existsIn) {
                    mConnectedCameras.add(camera);
                }
            }
        }
        Logger.t(TAG).e("camera connected: " + camera.getServerInfo());
        Logger.t(TAG).e("onCameraConnected current connected camera size: " + mConnectedCameras.size()
                + " connecting camera size: " + mConnectingCameras.size());

        int size = mConnectedCameras.size();
        if (size > 1) {
            CameraWrapper camera1 = mConnectedCameras.get(0);
            CameraWrapper camera2 = mConnectedCameras.get(1);
            Logger.t(TAG).d("camera port: " + camera1.getPort() + " " + camera2.getPort());
            if ((camera1.getPort() == EV_CAM_PORT && camera2.getPort() == VDT_CAM_PORT)
                    || (camera1.getPort() == VDT_CAM_PORT && camera2.getPort() == EV_CAM_PORT)) {
                //当VdtCamera和EvCamera同时存在时，优先连接EvCamera
                if (camera1.getPort() == VDT_CAM_PORT) {
                    Logger.t(TAG).d("releaseConnection: " + camera1.getServerInfo());
                    camera1.releaseConnection();
                    return false;
                } else if (camera2.getPort() == VDT_CAM_PORT) {
                    Logger.t(TAG).d("releaseConnection: " + camera2.getServerInfo());
                    camera2.releaseConnection();
                    return false;
                }
            }
        }
        return true;
    }

    private void updateLocalCameraInfo(CameraWrapper camera) {
        try {
            LocalCameraDaoManager manager = LocalCameraDaoManager.getInstance();
            CameraItem indb = manager.getCameraItem(camera.getSerialNumber());
            if (indb != null) {
                indb.setApiVersion(camera.getApiVersion());
                indb.setBspVersion(camera.getBspFirmware());
                indb.setHardwareName(camera.getHardwareName());
                if (!TextUtils.isEmpty(camera.getName())) {
                    indb.setCameraName(camera.getName());
                }
                MountVersion mountVersion = camera.getMountVersion();
                if (!TextUtils.isEmpty(mountVersion.hw_version)) {
                    indb.setMountHardwareVersion(mountVersion.hw_version);
                    indb.setMountSoftVersion(mountVersion.sw_version);
                    indb.setMountSupport4g(mountVersion.support_4g);
                }
                indb.setLastConnectingTime(System.currentTimeMillis());
                manager.update(indb);
            } else {
                CameraItem newItem = new CameraItem();
                newItem.setSerialNumber(camera.getSerialNumber());
                newItem.setApiVersion(camera.getApiVersion());
                newItem.setBspVersion(camera.getBspFirmware());
                newItem.setHardwareName(camera.getHardwareName());
                newItem.setCameraName(camera.getName());
                MountVersion mountVersion = camera.getMountVersion();
                if (!TextUtils.isEmpty(mountVersion.hw_version)) {
                    newItem.setMountHardwareVersion(mountVersion.hw_version);
                    newItem.setMountSoftVersion(mountVersion.sw_version);
                    newItem.setMountSupport4g(mountVersion.support_4g);
                }
                newItem.setLastConnectingTime(System.currentTimeMillis());
                manager.insert(newItem);
            }

        } catch (Exception ignored) {

        }
    }

    private synchronized void onCameraDisconnected(CameraWrapper camera) {
        // disconnect msg may be sent from msg thread,
        // need to stop it fully
        //vdtCamera.removeCallback(mCameraCallback);

        Logger.t(TAG).d("onCameraDisconnected: " + camera.getServerInfo());

        for (int i = 0; i < mConnectedCameras.size(); i++) {
            if (mConnectedCameras.get(i) == camera) {
                mConnectedCameras.remove(i);
                Logger.t(TAG).d("connected camera disconnected " + camera.getInetSocketAddress());
                break;
            }
        }

        for (int i = 0; i < mConnectingCameras.size(); i++) {
            if (mConnectingCameras.get(i) == camera) {
                mConnectingCameras.remove(i);
                Logger.t(TAG).d("connecting camera disconnected " + camera.getInetSocketAddress());
                break;
            }
        }

        for (int i = 0; i < mServiceList.size(); i++) {
            VdtCamera.ServiceInfo serviceInfo = mServiceList.get(i);

            if (serviceInfo.inetAddr.equals(camera.getAddress())
                    && serviceInfo.port == camera.getPort()) {
                mServiceList.remove(i);
                Logger.t(TAG).d("find camera disconnected " + camera.getInetSocketAddress());
                break;
            }
        }

        if (camera == mCurrentCamera) {
            if (mConnectedCameras.size() == 0) {
                mCurrentCamera = null;
                currentCameraObservable.onNext(Optional.empty());
            } else {
                mCurrentCamera = mConnectedCameras.get(0);
                Logger.t(TAG).e("now mCurrentCamera: " + mCurrentCamera);
                currentCameraObservable.onNext(Optional.of(mCurrentCamera));
                mRxBus.post(new CameraConnectionEvent(CameraConnectionEvent.VDT_CAMERA_SELECTED_CHANGED, null));
            }
        }

        Logger.t(TAG).e("onCameraDisconnected current connected camera size: " + mConnectedCameras.size()
                + " connecting camera size: " + mConnectingCameras.size());
        mRxBus.post(new CameraConnectionEvent(CameraConnectionEvent.VDT_CAMERA_DISCONNECTED, camera));
    }

    public static String constructKeyForDiskCache(Clip.ID cid, int rawDataType) {
        VdtCameraManager vdtCameraManager = VdtCameraManager.getManager();
        CameraWrapper currentCamera = vdtCameraManager.getCurrentCamera();
        if (currentCamera == null) return "";

        return String.valueOf(currentCamera.getSerialNumber()).toLowerCase() + cid.subType + cid.type + rawDataType;
    }

    private ICameraWrapper.OnConnectionChangeListener connectionChangeListener = new ICameraWrapper.OnConnectionChangeListener() {
        @Override
        public void onConnected(CameraWrapper camera) {
            mRxBus.post(new CameraConnectionEvent(CameraConnectionEvent.VDT_CAMERA_CONNECTING, camera));
        }

        @Override
        public void onConnectionFailed(CameraWrapper camera) {
            mRxBus.post(new CameraConnectionEvent(CameraConnectionEvent.VDT_CAMERA_CONNECTING_FAILED, camera));
        }

        @Override
        public void onVdbConnected(CameraWrapper camera) {
            boolean cameraConnected = onCameraConnected(camera);
            Logger.t(TAG).d("onVdbConnected cameraConnected: " + cameraConnected);
            if (cameraConnected) {
                if (mCurrentCamera != camera) {
                    mCurrentCamera = camera;
                    Logger.t(TAG).e("mCurrentCamera: " + camera);
                    currentCameraObservable.onNext(Optional.of(camera));
                }
                mRxBus.post(new CameraConnectionEvent(CameraConnectionEvent.VDT_CAMERA_CONNECTED, camera));
            } else {
                Logger.t(TAG).e("mCurrentCamera: " + mCurrentCamera + " camera: " + camera);
                // 只有在第二次连上的是evcam的时候才会去下发连接成功的事件
                if (camera.getPort() == EV_CAM_PORT) {
                    mCurrentCamera = camera;
                    currentCameraObservable.onNext(Optional.of(camera));
                    mRxBus.post(new CameraConnectionEvent(CameraConnectionEvent.VDT_CAMERA_CONNECTED, camera));
                }
            }
        }

        @Override
        public void onDisconnected(CameraWrapper camera) {
            onCameraDisconnected(camera);
        }
    };

}
