package com.mkgroup.camera.connectivity;

import android.content.Context;
import android.net.wifi.WifiManager;
import android.text.TextUtils;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.utils.ToStringUtils;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.VdtCamera;
import com.mkgroup.camera.preference.PreferenceUtils;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.jmdns.JmDNS;
import javax.jmdns.ServiceEvent;
import javax.jmdns.ServiceListener;

/**
 * Created by DoanVT on 2017/7/27.
 */
public class DeviceScanner extends Thread {
    private static final String TAG = DeviceScanner.class.getSimpleName();
    public static final String SERVICE_VIDIT_STUDIO = "Vidit Studio";
    private static final String SERVICE_TYPE = "_ccam._tcp.local.";
    public static final String SERVICE_VIDITCAM = "ViditCam";

    private static final int SCAN_INTERVAL = 1000;

    private VdtCameraManager mVdtCameraManager = VdtCameraManager.getManager();
    private List<InetAddress> mAddress = new ArrayList<>();
    private List<JmDNS> mDns = new ArrayList<>();
    private WifiManager.MulticastLock mLock;
    private JmDNS dns;

    private AtomicBoolean mbRunning = new AtomicBoolean(false);

    public DeviceScanner() {
        super(TAG);
    }

    public synchronized void startWork() {
        if (!mbRunning.get()) {
            mbRunning.set(true);
            start();
            allowMulticast();
        }
    }

    public synchronized void stopWork() {
        if (mbRunning.get()) {
            mbRunning.set(false);
            interrupt();
            notifyAll();
            releaseMulticast();
            dns.removeServiceListener(SERVICE_TYPE, mServiceListener);
        }
    }

    @Override
    public void run() {
        threadLoop();
    }

    private synchronized void threadLoop() {
        while (mbRunning.get()) {
            if (!mbRunning.get()) {
                break;
            }
            try {
                Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces();
                while (en.hasMoreElements()) {
                    NetworkInterface ni = en.nextElement();
                    Enumeration<InetAddress> enumIpAddr = ni.getInetAddresses();
                    while (enumIpAddr.hasMoreElements()) {
                        InetAddress inetAddress = enumIpAddr.nextElement();
                        if (inetAddress.isSiteLocalAddress()) {
                            Logger.t(TAG).e("inetAddress: " + inetAddress);
                            mAddress.add(inetAddress);
                        }
                    }
                }

                for (InetAddress addr : mAddress) {
                    dns = JmDNS.create(addr, SERVICE_VIDITCAM);
                    mDns.add(dns);
                    dns.addServiceListener(SERVICE_TYPE, mServiceListener);
                }

                wait(SCAN_INTERVAL * 5);

                for (JmDNS dns : mDns) {
                    dns.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                mAddress.clear();
                mDns.clear();
            }

            try {
                Thread.sleep(SCAN_INTERVAL);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        }
    }

    ServiceListener mServiceListener = new ServiceListener() {
        @Override
        public void serviceAdded(ServiceEvent event) {
            Logger.t(TAG).e("serviceAdded: " + event.getName() + ", " + event.getType());
            Logger.t(TAG).e(event.getInfo().toString());
            // Vidit Camera, _ccam._tcp.local.
            event.getDNS().requestServiceInfo(event.getType(), event.getName(), 1);
        }

        @Override
        public void serviceRemoved(ServiceEvent event) {
            Logger.t(TAG).e("serviceRemoved: " + event.getName() + ", " + event.getType());
            Logger.t(TAG).e(event.getInfo().toString());
        }

        @Override
        public void serviceResolved(ServiceEvent event) {
            Logger.t(TAG).e("serviceResolved: " + event.getName() + ", " + event.getType() + ", " + event.getInfo().getServer());

            javax.jmdns.ServiceInfo info = event.getInfo();

            InetAddress[] inetAddresses = info.getInetAddresses();

            printAddr("inetAddresses", inetAddresses);

            if (inetAddresses.length > 0) {
                String name = event.getName();
                boolean bIsPcServer = name.equals(SERVICE_VIDIT_STUDIO);
                String serverName = info.getServer();

                Logger.t(TAG).e("serverName: " + serverName);

                int index = serverName.indexOf(".local.");
                if (index >= 0 && !TextUtils.isEmpty(name)) {
                    Logger.t(TAG).e("first filter: " + event.getInfo().toString());

                    serverName = serverName.substring(0, index);
                    if (name.startsWith(CameraDiscovery.TARGET_SERVICE) || PreferenceUtils.getBoolean(PreferenceUtils.KEY_SHOW_ALL_CAMERAS, false)) {

                        //过滤正在连接的camera，防止多次发起连接
                        List<CameraWrapper> connectingVdtCameras = mVdtCameraManager.getConnectingVdtCameras();
                        boolean filter = false;
                        for (CameraWrapper itemCamera : connectingVdtCameras) {
                            VdtCamera.ServiceInfo serverInfo = itemCamera.getServerInfo();
                            //这里过滤的判定可能不太准确
                            if (serverName.equals(serverInfo.serverName)) {
                                filter = true;
                                break;
                            }
                        }

                        if (!filter) {
                            //这里取的inetAddresses[0]可能有问题，没有区分ipv4，ipv6
                            VdtCamera.ServiceInfo serviceInfo = new VdtCamera.ServiceInfo(inetAddresses[0], info
                                    .getPort(), serverName, name, bIsPcServer);
                            Logger.t(TAG).e("second filter: " + serviceInfo.toString());

                            mVdtCameraManager.connectCamera(serviceInfo, "mDNS");
                        }
                    }
                }
            }
        }
    };

    private void printAddr(String flag, InetAddress[] inetAddresses) {
        for (InetAddress address :
                inetAddresses) {
            Logger.t(flag).e(flag + ": " + address.toString());
        }
    }

    private void allowMulticast() {
        WifiManager wifiManager = (WifiManager) WaylensCamera.getInstance().getApplicationContext()
                .getSystemService(Context.WIFI_SERVICE);
        if (wifiManager == null) {
            return;
        }
        mLock = wifiManager.createMulticastLock("multicast.test");
        if (mLock != null) {
            try {
                mLock.acquire();
            } catch (Exception ex) {
                Logger.t(TAG).e("%s", ToStringUtils.getString(ex));
            }
        }
    }

    private void releaseMulticast() {
        if (mLock != null) {
            mLock.release();
            mLock = null;
        }
    }
}