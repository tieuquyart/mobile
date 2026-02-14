package com.mkgroup.camera.connectivity;

import android.content.Context;
import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.preference.PreferenceUtils;

import java.util.concurrent.atomic.AtomicBoolean;

import static android.net.nsd.NsdManager.FAILURE_ALREADY_ACTIVE;
import static android.net.nsd.NsdManager.FAILURE_INTERNAL_ERROR;
import static android.net.nsd.NsdManager.FAILURE_MAX_LIMIT;

/**
 * Created by DoanVT on 2017/7/27.
 */
public class CameraDiscovery {
    private static final String TAG = "CameraDiscovery";

    private static volatile CameraDiscovery mInstance;

    private static final String SERVICE_TYPE = "_ccam._tcp";
    private static final String SERVICE_TYPE_EVCAM = "_evcam._tcp";

    static final String TARGET_SERVICE = "Waylens 360";
    private static final String TARGER_SERVICE_EVCAM = "EV Camera";

    private NsdManager mNsdManager;
    private NsdManager mEvCamNsdManager;

    private NsdManager.DiscoveryListener mDiscoveryListener;
    private NsdManager.DiscoveryListener mEvCamDiscoveryListener;

    private AtomicBoolean mIsStarted = new AtomicBoolean(false);
    private AtomicBoolean mEvCamIsStarted = new AtomicBoolean(false);

    public static CameraDiscovery getInstance() {
        if (mInstance == null) {
            synchronized (CameraDiscovery.class) {
                if (mInstance == null) {
                    mInstance = new CameraDiscovery();
                }
            }
        }
        return mInstance;
    }

    /**
     * Discovery the available cameras
     *
     * @param context
     * @param callback
     */
    public void discoverCameras(Context context, final Callback callback) {
        discoverEvCamImpl(context, callback);
        discoverCamerasImpl(context, callback);
    }

    public boolean isStarted() {
        return mIsStarted.get() || mEvCamIsStarted.get();
    }

    public void stopDiscovery() {
        stopDiscoveryImpl();
    }

    private void discoverCamerasImpl(Context context, final Callback callback) {
        mNsdManager = (NsdManager) context.getSystemService(Context.NSD_SERVICE);
        mDiscoveryListener = new NsdManager.DiscoveryListener() {

            @Override
            public void onStartDiscoveryFailed(String serviceType, int errorCode) {
                mIsStarted.set(false);
                callback.onError(errorCode);
                Logger.t(TAG).e("onStartDiscoveryFailed: " + errorCode);
            }

            @Override
            public void onStopDiscoveryFailed(String serviceType, int errorCode) {
                Logger.t(TAG).e("onStopDiscoveryFailed: " + errorCode);
            }

            @Override
            public void onDiscoveryStarted(String serviceType) {
                mIsStarted.set(true);
                Logger.t(TAG).e("onDiscoveryStarted: " + serviceType);
            }

            @Override
            public void onDiscoveryStopped(String serviceType) {
                mIsStarted.set(false);
                Logger.t(TAG).e("onDiscoveryStopped: " + serviceType);
            }

            @Override
            public void onServiceFound(NsdServiceInfo serviceInfo) {
                mIsStarted.set(true);
                mNsdManager.resolveService(serviceInfo, createResolveListener(callback));
                Logger.t(TAG).e("onServiceFound: " + serviceInfo.toString());
            }

            @Override
            public void onServiceLost(NsdServiceInfo serviceInfo) {
                mIsStarted.set(false);
                Logger.t(TAG).e("onServiceLost");
            }
        };
        //no NsdManager in unit test or other case
        if (mNsdManager != null) {
            mNsdManager.discoverServices(SERVICE_TYPE, NsdManager.PROTOCOL_DNS_SD, mDiscoveryListener);
        }
    }

    private void discoverEvCamImpl(Context context, Callback callback) {
        mEvCamNsdManager = (NsdManager) context.getSystemService(Context.NSD_SERVICE);
        mEvCamDiscoveryListener = new NsdManager.DiscoveryListener() {
            @Override
            public void onStartDiscoveryFailed(String serviceType, int errorCode) {
                mEvCamIsStarted.set(false);
                callback.onError(errorCode);
                Logger.t(TAG).e("onStartDiscoveryFailed: " + errorCode);
            }

            @Override
            public void onStopDiscoveryFailed(String serviceType, int errorCode) {
                Logger.t(TAG).e("onStopDiscoveryFailed: " + errorCode);
            }

            @Override
            public void onDiscoveryStarted(String serviceType) {
                mEvCamIsStarted.set(true);
                Logger.t(TAG).e("onDiscoveryStarted: " + serviceType);
            }

            @Override
            public void onDiscoveryStopped(String serviceType) {
                mEvCamIsStarted.set(false);
                Logger.t(TAG).e("onDiscoveryStopped: " + serviceType);
            }

            @Override
            public void onServiceFound(NsdServiceInfo serviceInfo) {
                mEvCamIsStarted.set(true);
                mEvCamNsdManager.resolveService(serviceInfo, createResolveListener(callback));
                Logger.t(TAG).e("onServiceFound: " + serviceInfo.toString());
            }

            @Override
            public void onServiceLost(NsdServiceInfo serviceInfo) {
                mEvCamIsStarted.set(false);
                Logger.t(TAG).e("onServiceLost");
            }
        };

        if (mEvCamNsdManager != null) {
            mEvCamNsdManager.discoverServices(SERVICE_TYPE_EVCAM, NsdManager.PROTOCOL_DNS_SD, mEvCamDiscoveryListener);
        }
    }

    private NsdManager.ResolveListener createResolveListener(final Callback callback) {
        return new NsdManager.ResolveListener() {
            @Override
            public void onResolveFailed(NsdServiceInfo serviceInfo, int errorCode) {
                callback.onError(errorCode);
                switch (errorCode) {
                    case FAILURE_ALREADY_ACTIVE:
                        Logger.t(TAG).e("onResolveFailed: FAILURE_ALREADY_ACTIVE");
                        break;
                    case FAILURE_MAX_LIMIT:
                        Logger.t(TAG).e("onResolveFailed: FAILURE_MAX_LIMIT");
                        break;
                    case FAILURE_INTERNAL_ERROR:
                        Logger.t(TAG).e("onResolveFailed: FAILURE_INTERNAL_ERROR");
                        break;
                    default:
                        Logger.t(TAG).e("onResolveFailed: " + errorCode);
                        break;
                }
            }

            @Override
            public void onServiceResolved(NsdServiceInfo serviceInfo) {
                Logger.t(TAG).e("onServiceResolved: " + serviceInfo.toString());
//                Logger.t(TAG).e("onServiceResolved: " + serviceInfo.getServiceName() + serviceInfo.getHost() + ":" + serviceInfo.getPort());
                String serviceName = serviceInfo.getServiceName();
                if (((serviceName != null)
                        && (serviceName.startsWith(TARGET_SERVICE) || serviceName.startsWith(TARGER_SERVICE_EVCAM)))
                        || PreferenceUtils.getBoolean(PreferenceUtils.KEY_SHOW_ALL_CAMERAS, false)) {
                    callback.onCameraFound(serviceInfo);
                }
            }
        };
    }

    public void stopDiscoveryImpl() {
        if (mNsdManager != null && mIsStarted.get()) {
            mNsdManager.stopServiceDiscovery(mDiscoveryListener);
        }

        if (mEvCamNsdManager != null && mEvCamIsStarted.get()) {
            mEvCamNsdManager.stopServiceDiscovery(mEvCamDiscoveryListener);
        }
    }

    public interface Callback {
        void onCameraFound(NsdServiceInfo cameraService);

        void onError(int errorCode);
    }
}
