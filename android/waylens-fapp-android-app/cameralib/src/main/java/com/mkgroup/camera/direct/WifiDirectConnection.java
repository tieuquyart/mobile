package com.mkgroup.camera.direct;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.net.wifi.WifiManager;
import android.net.wifi.p2p.WifiP2pConfig;
import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pInfo;
import android.net.wifi.p2p.WifiP2pManager;
import android.os.Build;
import android.os.Looper;
import android.text.TextUtils;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.command.EvCameraCmdConsts;
import com.mkgroup.camera.event.DirectConnectionEvent;
import com.mkgroup.camera.rest.NetworkService;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.rest.ServerErrorHandler;
import com.mkgroup.camera.utils.RxBus;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.VdtCamera;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.PublishSubject;

import static com.mkgroup.camera.command.VdtCameraCmdConsts.VDT_CAM_PORT;
import static com.mkgroup.camera.connectivity.IPLink.IP_EVCAM;
import static com.mkgroup.camera.connectivity.IPLink.IP_VDTCAM;

import androidx.core.app.ActivityCompat;

/**
 * Created by doanvt on 2019/2/15.
 * Email：doanvt-hn@mk.com.vn
 */

public class WifiDirectConnection implements DirectActionListener {

    private final static String TAG = WifiDirectConnection.class.getSimpleName();

    private final static String PREFIX_NAME = "Waylens-";

    private static volatile WifiDirectConnection mDirectConnection;

    private boolean mFeatureEnabled = true;

    private boolean mRegisterReceiver = false;

    private Context mContext;

    private Disposable searchDisposable;

    private PublishSubject<Optional<String>> searchCamera = PublishSubject.create();

    private Disposable scanDisposable;

    private WifiP2pManager wifiP2pManager;
    private WifiP2pManager.Channel mChannel;
    private WifiDirectReceiver receiver;

    private boolean mWifiP2pEnabled;

    private List<WifiP2pDevice> mAllDevicesList = new ArrayList<>(); // 附近可用的p2p设备
    private List<WifiP2pDevice> mWaylensList = new ArrayList<>(); // 附近可用的waylens设备
    private Map<WifiP2pDevice, Boolean> mDevicesMap = new HashMap<>(); // 附近可用的且在用户名下的waylens设备
    private WifiP2pDevice mWifiP2pDevice; // 当前请求连接的waylens设备
    private WifiP2pDevice mConnectedDevice; // 当前已经连接的waylens设备

    private String mTempSerialNum;

    public static WifiDirectConnection getInstance() {
        if (mDirectConnection == null) {
            synchronized (WifiDirectConnection.class) {
                if (mDirectConnection == null) {
                    mDirectConnection = new WifiDirectConnection();
                }
            }
        }
        return mDirectConnection;
    }

    private WifiDirectConnection() {
        this.mContext = WaylensCamera.getInstance().getApplicationContext();
    }

    private void searchCamera(String address) {
        Logger.t(TAG).d("startConnectCamera mConnectedDevice = " + mConnectedDevice + " address = " + address);

        if (TextUtils.isEmpty(address)) {
            if (mConnectedDevice != null) {
                String deviceName = mConnectedDevice.deviceName;
                if (deviceName.contains(PREFIX_NAME)) {
                    connectEvCamera();
                    connectVdtCamera();
                } else if (checkDeviceValid(deviceName)) {
                    connectNewEvCamera();
                }
            }
        } else {
            connectSpecifyCamera(address);
        }
    }

    private void connectSpecifyCamera(String address) {
        try {
            InetAddress byName = InetAddress.getByName(address);

            if (byName == null) {
                return;
            }
            boolean reachable = byName.isReachable(1000);
            Logger.t(TAG).d("connectSpecifyCamera ip reachable: " + reachable);

            if (reachable) {
                VdtCamera.ServiceInfo serviceInfo = new VdtCamera.ServiceInfo(byName, EvCameraCmdConsts.EV_CAM_PORT,
                        "fleet", "", false);
                VdtCameraManager.getManager().connectCamera(serviceInfo, "P2P_SpecifyCamera");
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectSpecifyCamera UnknownHostException: " + e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectSpecifyCamera IOException: " + e.getMessage());
        }
    }

    private void connectNewEvCamera() {
        try {
            InetAddress byName = InetAddress.getByName(IP_EVCAM);
            if (byName == null) {
                return;
            }
            boolean reachable = byName.isReachable(1000);
            Logger.t(TAG).d("connectNewEvCamera ip reachable: " + reachable);

            if (reachable) {
                VdtCamera.ServiceInfo serviceInfo = new VdtCamera.ServiceInfo(byName, EvCameraCmdConsts.EV_CAM_PORT,
                        "fleet", "", false);
                VdtCameraManager.getManager().connectCamera(serviceInfo, "P2P_NewEvCamera");
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectNewEvCamera UnknownHostException: " + e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectNewEvCamera IOException: " + e.getMessage());
        }
    }

    private void connectEvCamera() {
        try {
            InetAddress byName = InetAddress.getByName(IP_VDTCAM);
            if (byName == null) {
                return;
            }
            boolean reachable = byName.isReachable(1000);
            Logger.t(TAG).d("connectEvCamera ip reachable: " + reachable);

            if (reachable) {
                VdtCamera.ServiceInfo serviceInfo = new VdtCamera.ServiceInfo(byName, EvCameraCmdConsts.EV_CAM_PORT,
                        "horn", "", false);
                VdtCameraManager.getManager().connectCamera(serviceInfo, "P2P_EvCamera");
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectEvCamera UnknownHostException: " + e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectEvCamera IOException: " + e.getMessage());
        }
    }

    private void connectVdtCamera() {
        try {
            InetAddress byName = InetAddress.getByName(IP_VDTCAM);
            if (byName == null) {
                return;
            }
            boolean reachable = byName.isReachable(1000);
            Logger.t(TAG).d("connectVdtCamera ip reachable: " + reachable);

            if (reachable) {
                VdtCamera.ServiceInfo serviceInfo = new VdtCamera.ServiceInfo(byName, VDT_CAM_PORT,
                        "horn", "", false);
                VdtCameraManager.getManager().connectCamera(serviceInfo, "P2P_VdtCamera");
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectVdtCamera UnknownHostException: " + e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectVdtCamera IOException: " + e.getMessage());
        }
    }

    public void registerP2PReceiver() {
        Logger.t(TAG).d("registerP2PReceiver: " + mFeatureEnabled);
        //由于是第一次安装，尚未获得location权限，此时不会调用onDisconnection()绑定当前网络
        //所以走setup流程连接相机后并不会显示，暂时用解开注释解决（ps：忘记为什么注掉了）
        NetworkService.bindNetworkToWiFi();

        if (!mFeatureEnabled) {
            mRegisterReceiver = false;
//            ApiService.bindNetworkToWiFi();
            return;
        }

        WifiManager wifiManager = (WifiManager) mContext.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        if (wifiManager == null) {
            Logger.t(TAG).e("wifiManager == null");
//            ApiService.bindNetworkToWiFi();
            return;
        }

        //先打开wifi，再初始化Wi-Fi Direct
        int wifiState = wifiManager.getWifiState();
        Logger.t(TAG).d("wifiState enable: " + (wifiState == WifiManager.WIFI_STATE_ENABLED));
        if (wifiState != WifiManager.WIFI_STATE_ENABLED) {
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
                // do nothing here
            } else {
                wifiManager.setWifiEnabled(true);
            }
        }

        wifiP2pManager = (WifiP2pManager) mContext.getSystemService(Context.WIFI_P2P_SERVICE);
        if (wifiP2pManager == null) {
            Logger.t(TAG).e("wifiP2pManager == null");
//            ApiService.bindNetworkToWiFi();
            return;
        }

        mChannel = wifiP2pManager.initialize(mContext, Looper.getMainLooper(), this);

        receiver = new WifiDirectReceiver(wifiP2pManager, mChannel, this);
        mContext.registerReceiver(receiver, receiver.getIntentFilter());

        searchDisposable = searchCamera
                .observeOn(Schedulers.io())
                .subscribe(optional -> searchCamera(optional.get()), new ServerErrorHandler(TAG));

        //当前没有连接到p2p设备且wifi也没有连接相机时, 10s扫描一次, 扫描一分钟
        final int count = 6;
        scanDisposable = Observable.interval(10, TimeUnit.SECONDS)
                .take(count)
                .filter(aLong -> (mConnectedDevice == null && !currentConnected()))
                .subscribeOn(Schedulers.io())
                .subscribe(aLong -> discoverPeers(), new ServerErrorHandler());

        mRegisterReceiver = true;
    }

    private void releaseSearch() {
        if (searchDisposable != null && !searchDisposable.isDisposed()) {
            searchDisposable.dispose();
        }
        if (scanDisposable != null && !scanDisposable.isDisposed()) {
            scanDisposable.dispose();
        }
    }

    public void unregisterP2PReceiver() {
        Logger.t(TAG).d("unregisterP2PReceiver: " + mRegisterReceiver);
        try {
            if (mRegisterReceiver) {
                mRegisterReceiver = false;
                onDeviceDisconnect();
                releaseSearch();
                mContext.unregisterReceiver(receiver);
            }
        } catch (Exception ex) {
            Logger.t(TAG).e("unregisterP2PReceiver error: " + ex.getMessage());
        }
    }

    public void switchFeature(boolean enable) {
        Logger.t(TAG).e("switchFeature: " + enable + " mRegisterReceiver: " + mRegisterReceiver);
        if (mFeatureEnabled == enable) {
            return;
        }

        this.mFeatureEnabled = enable;

        if (!mFeatureEnabled) {
            onDeviceDisconnect();
        } else if (!mRegisterReceiver) {
            //防止未注册监听，导致收不到广播事件
            registerP2PReceiver();
        }
    }

    @Override
    public void wifiP2pEnabled(boolean enabled) {
        Logger.t(TAG).d("wifiP2pEnabled: " + enabled);
        this.mWifiP2pEnabled = enabled;
        adaptationForAndroidQ();
    }

    private void adaptationForAndroidQ() {
        // android Q 适配
        if (mWifiP2pEnabled && Build.VERSION.SDK_INT > Build.VERSION_CODES.P) {
            wifiP2pManager.requestNetworkInfo(mChannel, networkInfo -> {
                Logger.t(TAG).i("requestNetworkInfo onNetworkInfoAvailable = " + networkInfo);
                if (networkInfo.isConnected()) {
                    wifiP2pManager.requestConnectionInfo(mChannel, info -> {
                        Logger.t(TAG).i("requestConnectionInfo onConnectionInfoAvailable = " + info);
                        WifiDirectConnection.this.onConnectionInfoAvailable(info);
                    });
                } else {
                    onDisconnection();
                }
            });
        }
    }

    public void discoverPeers() {
        Logger.t(TAG).d("discoverPeers");
        if (mWifiP2pEnabled) {
            if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                return;
            }
            wifiP2pManager.discoverPeers(mChannel, new WifiP2pManager.ActionListener() {
                @Override
                public void onSuccess() {
                    Logger.t(TAG).d("discoverPeers onSuccess");
                }

                @Override
                public void onFailure(int reason) {
                    Logger.t(TAG).d("discoverPeers onFailure: " + reason);
                }
            });
        }
    }

    @Override
    public void onConnectionInfoAvailable(WifiP2pInfo wifiP2pInfo) {
        InetAddress ownerAddress = wifiP2pInfo.groupOwnerAddress;
        Logger.t(TAG).d("onConnectionInfoAvailable: " + ownerAddress);
        if (ownerAddress != null) {
            String hostAddress = ownerAddress.getHostAddress();
//            Logger.t(TAG).d("hostAddress: " + hostAddress);

            if (hostAddress.startsWith("192.168")) {
                //当手机wifi已连接到某个相机时，不再进行p2p的连接相机
//                if (currentConnected()) {
//                    return;
//                }

                onDeviceConnected(mWifiP2pDevice, hostAddress);
                mWifiP2pDevice = null;
            } else {
                NetworkService.bindNetworkToWiFi();
            }
        } else {
            NetworkService.bindNetworkToWiFi();
        }
    }

    private boolean currentConnected() {
        CameraWrapper currentCamera = VdtCameraManager.getManager().getCurrentCamera();
        List<CameraWrapper> connectingCameras = VdtCameraManager.getManager().getConnectingVdtCameras();

        Logger.t(TAG).d("currentConnected: " + (currentCamera != null ? currentCamera.getSerialNumber() : null)
                + " connectingCameras: " + connectingCameras.size());
        return currentCamera != null || connectingCameras.size() != 0;
    }

    @Override
    public void onDisconnection() {
        Logger.t(TAG).d("onDisconnection");
        //过滤掉默认断开连接的广播
        if (mConnectedDevice != null || mWifiP2pDevice != null) {
            RxBus.getDefault().post(new DirectConnectionEvent(DirectConnectionEvent.WIFI_DIRECT_DISCONNECTED));
        }
        onDeviceDisconnect();
    }

    private void onDeviceDisconnect() {
        mConnectedDevice = null;
        mWifiP2pDevice = null;
        NetworkService.bindNetworkToWiFi();
    }

    @Override
    public void onSelfDeviceAvailable(WifiP2pDevice wifiP2pDevice) {
//        Logger.t(TAG).d("onSelfDeviceAvailable: " + wifiP2pDevice);
    }

    //android 9 samsung
    //WifiPermissionsUtil: canAccessScanResults: pkgName = com.mk.autosecure, uid = 10289
    //isLocationModeEnabled
    //WifiP2pService: Security Exception, cannot access peer list
    @Override
    public synchronized void onPeersAvailable(Collection<WifiP2pDevice> wifiP2pDeviceList) {
        Logger.t(TAG).d("onPeersAvailable: " + wifiP2pDeviceList.size());

        Logger.t(TAG).d("onPeersAvailable mConnectedDevice: " + mConnectedDevice + " mWifiP2pDevice: " + mWifiP2pDevice);
        //当附近有N台设备可用时，就会有N个广播回调，这里过滤掉多余的广播
        if (mAllDevicesList.containsAll(wifiP2pDeviceList) && (mConnectedDevice != null || mWifiP2pDevice != null)) {
            Logger.t(TAG).d("filter duplicate broadcast");
            return;
        }

        mDevicesMap.clear();
        mWaylensList.clear();
        mAllDevicesList.clear();

        mAllDevicesList.addAll(wifiP2pDeviceList);

        for (WifiP2pDevice p2pDevice : wifiP2pDeviceList) {
            int status = p2pDevice.status;
            //过滤设备可用
            if (status == WifiP2pDevice.AVAILABLE || status == WifiP2pDevice.INVITED) {
                String deviceName = p2pDevice.deviceName;
                Logger.t(TAG).d("deviceName: " + deviceName);
                //过滤waylens设备
                if (deviceName.contains(PREFIX_NAME)) {
                    mWaylensList.add(p2pDevice);

                    String substring = deviceName.replace("\"", "").substring(8);

                    mDevicesMap.put(p2pDevice, false);

                    //过滤是否临时连接
                    Logger.t(TAG).d("scanDevice: " + substring + " mTempSerialNum: " + mTempSerialNum);
                    if (substring.equals(mTempSerialNum)) {
                        mDevicesMap.put(p2pDevice, true);
                    }
                } else if (checkDeviceValid(deviceName)) {
                    mWaylensList.add(p2pDevice);
                    mDevicesMap.put(p2pDevice, false);
                }
            } else if (status == WifiP2pDevice.CONNECTED) {
                //当手机wifi已连接到某个相机时，不再进行p2p的连接相机
//                if (currentConnected()) {
//                    return;
//                }

                Logger.t(TAG).d("status == WifiP2pDevice.CONNECTED");
                onDeviceConnected(p2pDevice, "");
                break;
            }
        }

        int size = mDevicesMap.size();
        Logger.t(TAG).d("user own devicesList: " + size);

        // TODO: 2019/3/19 当存在多个设备时，随着homepage的切换，而切换连接设备
        WifiP2pDevice curDevice = null;
        for (Map.Entry<WifiP2pDevice, Boolean> entry : mDevicesMap.entrySet()) {
            Boolean value = entry.getValue();
            if (value) {
                curDevice = entry.getKey();
                break;
            } else {
                curDevice = entry.getKey();
            }
        }

        if (curDevice != null) {
            connectDevice(curDevice);
        }
    }

    private boolean checkDeviceValid(String deviceName) {
        try {
            if (TextUtils.isEmpty(deviceName) || deviceName.length() <= 3) {
                return false;
            }
            deviceName = deviceName.replace("\"", "");
            Logger.t(TAG).i("checkDeviceValid deviceName = " + deviceName);
            boolean a1 = Character.isDigit(deviceName.charAt(0));
            String s2 = deviceName.substring(1, 2);
            boolean a2 = TextUtils.equals("A", s2) || TextUtils.equals("B", s2);
            String s3 = deviceName.substring(2, 3);
            boolean b = TextUtils.equals("1", s3) || TextUtils.equals("2", s3) || TextUtils.equals("3", s3);
            return a1 && a2 && b;
        } catch (Exception ex) {
            Logger.t(TAG).e("checkDeviceValid Exception = " + ex.getMessage());
            return false;
        }
    }

    private void onDeviceConnected(WifiP2pDevice p2pDevice, String address) {
        Logger.t(TAG).i("onDeviceConnected p2pDevice = " + p2pDevice + " address = " + address);
        mConnectedDevice = p2pDevice;

        NetworkService.unbindNetworkToWiFi();
        searchCamera.onNext(Optional.of(address));

        RxBus.getDefault().post(new DirectConnectionEvent(DirectConnectionEvent.WIFI_DIRECT_CONNECTED));
    }

    /**
     * 连接p2p设备
     */
    public synchronized void connectDevice(WifiP2pDevice wifiP2pDevice) {
        Logger.t(TAG).d("connectDevice mConnectedDevice: " + mConnectedDevice + " wifiP2pDevice: " + wifiP2pDevice.deviceName);
        if (wifiP2pDevice.status == WifiP2pDevice.AVAILABLE) {
            // 这里 mConnectedDevice 应该是空值，但是并没有被赋值为null
//            if (mConnectedDevice != wifiP2pDevice && wifiP2pDevice.status == WifiP2pDevice.AVAILABLE) {
            mWifiP2pDevice = wifiP2pDevice;

            // 连接前REQUEST_PEERS，防止WifiP2pServiceImpl#isConfigValid()判断配置无效，导致丢弃连接请求
            // 但是有可能onPeersAvailable()尚未回调，就执行连接请求，此时会失败，所以会提示try again
            discoverPeers();

            WifiP2pConfig config = new WifiP2pConfig();
            config.deviceAddress = wifiP2pDevice.deviceAddress;

            if (ActivityCompat.checkSelfPermission(mContext, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                return;
            }
            wifiP2pManager.connect(mChannel, config, new WifiP2pManager.ActionListener() {
                @Override
                public void onSuccess() {
                    Logger.t(TAG).d("connect onSuccess");
                    // 并不一定是因为这里连接上的，而是可能因为 cameraDiscovery 扫描到了
                    adaptationForAndroidQ();
                }

                @Override
                public void onFailure(int reason) {
                    mWifiP2pDevice = null;
                    Logger.t(TAG).d("connect onFailure: " + reason);
                    RxBus.getDefault().post(new DirectConnectionEvent(DirectConnectionEvent.WIFI_DIRECT_CONNECTING_FAILED));
                }
            });
        } else {
            Logger.t(TAG).d("connectDevice wifiP2pDevice status: " + wifiP2pDevice.status);
        }
    }

    public void setTempConnectSN(String serialNum) {
        if (TextUtils.isEmpty(serialNum)) {
            this.mTempSerialNum = serialNum;
        } else {
            this.mTempSerialNum = serialNum.substring(3);
        }
    }

    @Override
    public void onChannelDisconnected() {
//        Logger.t(TAG).d("onChannelDisconnected");
    }

    public Map<WifiP2pDevice, Boolean> getDevicesMap() {
        return mDevicesMap;
    }

    public WifiP2pDevice getConnectedDevice() {
        return mConnectedDevice;
    }

    public List<WifiP2pDevice> getWaylensList() {
        return mWaylensList;
    }

}
