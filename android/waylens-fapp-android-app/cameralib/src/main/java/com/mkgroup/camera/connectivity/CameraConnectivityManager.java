package com.mkgroup.camera.connectivity;

import android.content.Context;
import android.net.nsd.NsdServiceInfo;
import android.net.wifi.WifiManager;

import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.utils.ToStringUtils;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.VdtCamera;

import java.util.concurrent.atomic.AtomicBoolean;


/**
 * Created by DoanVT on 2017/7/27.
 * Email: doanvt-hn@mk.com.vn
 */

public class CameraConnectivityManager {
    private static final String TAG = CameraConnectivityManager.class.getSimpleName();
    private static volatile CameraConnectivityManager _INSTANCE;

    private AtomicBoolean isStarted = new AtomicBoolean(false);
    private DeviceScanner mScanner;
    private WifiManager.MulticastLock mLock;

    public static CameraConnectivityManager getManager() {
        if (_INSTANCE == null) {
            synchronized (CameraConnectivityManager.class) {
                if (_INSTANCE == null) {
                    _INSTANCE = new CameraConnectivityManager();
                }
            }
        }
        return _INSTANCE;
    }

    private CameraConnectivityManager() {
    }

    public void startSearchCamera() {

        //强制连接固定IP
//        IPLink.linkIP();

        if (isStarted.get()) {
            return;
        }

        Logger.t(TAG).e("start search camera");

        //当发现列表为空时，10s强制连接一次
//        Observable.interval(10, TimeUnit.SECONDS)
//                .subscribeOn(Schedulers.io())
//                .subscribe(aLong -> {
//                    List<VdtCamera.ServiceInfo> serviceList = VdtCameraManager.getManager().getServiceList();
//                    if (serviceList.size() == 0) {
//                        IPLink.linkIP();
//                    }
//                }, new ServerErrorHandler());

        //启用android NSD_SERVICE
        CameraDiscovery.getInstance().discoverCameras(WaylensCamera.getInstance().getApplicationContext(), new CameraDiscovery.Callback() {
            @Override
            public void onCameraFound(NsdServiceInfo cameraService) {
                Logger.t(TAG).e("onCameraFound: " + cameraService.toString());

                String serviceName = cameraService.getServiceName();
                boolean bIsPcServer = serviceName.equals("Vidit Studio");

                final VdtCamera.ServiceInfo serviceInfo = new VdtCamera.ServiceInfo(
                        cameraService.getHost(),
                        cameraService.getPort(),
                        "", serviceName, bIsPcServer);

                VdtCameraManager.getManager().connectCamera(serviceInfo, "CameraDiscovery");
            }

            @Override
            public void onError(int errorCode) {
                Logger.t(TAG).e("errorCode: " + errorCode);
            }
        });

        //启用mDNS协议接收组播
//        startDeviceScanner();

        //启用接受组播设置
        allowMulticast();

        isStarted.set(true);
    }

    private void startDeviceScanner() {
        if (mScanner != null) {
            mScanner.stopWork();
        }
        mScanner = new DeviceScanner();
        mScanner.startWork();
    }

    private void stopDeviceScanner() {
        if (mScanner != null) {
            mScanner.stopWork();
        }
    }

    public void stopSearchCamera() {
        if (isStarted.get()) {
            Logger.t(TAG).e("stop search camera");
            CameraDiscovery.getInstance().stopDiscovery();
//            stopDeviceScanner();
            isStarted.set(false);
        }
    }

    //添加组播设置，否则pixel(android Q)在client模式下搜索不到相机，不过别的手机可以搜到
    private void allowMulticast() {
        WifiManager wifiManager = (WifiManager) WaylensCamera.getInstance().getApplicationContext()
                .getSystemService(Context.WIFI_SERVICE);
        if (wifiManager == null) {
            return;
        }
        mLock = wifiManager.createMulticastLock("multicast.test");
        if (mLock != null) {
            try {
                Logger.t(TAG).d("allowMulticast");
                mLock.acquire();
            } catch (Exception ex) {
                Logger.t(TAG).e("acquire error: %s", ToStringUtils.getString(ex));
            }
        }
    }

    private void releaseMulticast() {
        if (mLock != null) {
            Logger.t(TAG).d("releaseMulticast");
            mLock.release();
            mLock = null;
        }
    }

}
