package com.mk.autosecure.libs.utils;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.os.Build;
import android.telephony.TelephonyManager;

import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.VdtCameraManager;

/**
 * Created by DoanVT on 2017/10/25.
 * Email: doanvt-hn@mk.com.vn
 */

public class NetworkUtils {

    private final static String TAG = NetworkUtils.class.getSimpleName();

    public static boolean isNetworkLimited() {
        VdtCameraManager manager = VdtCameraManager.getManager();
        if (manager == null) {
            return false;
        }
//        Logger.t(TAG).d("ConnectedCamera size: " + manager.getConnectedCameras().size());

        if (manager.getConnectedCameras().size() != 0) {
            return true;
        } else {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                ConnectivityManager connectivityManager = (ConnectivityManager) HornApplication.getContext()
                        .getSystemService(Context.CONNECTIVITY_SERVICE);

                if (connectivityManager != null) {
                    Network activeNetwork = connectivityManager.getActiveNetwork();
                    NetworkCapabilities capabilities = connectivityManager.getNetworkCapabilities(activeNetwork);
                    if (capabilities != null) {
                        //判断网络是否真正连通
                        boolean validated = capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED);
                        Logger.t(TAG).e("Capability validated: " + validated + " " + Build.MANUFACTURER);
//                    boolean internet = capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET);
//                    Logger.t(TAG).e("internet: " + internet);
                        return !validated;
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }

    public static boolean inHotspotMode() {
        VdtCameraManager manager = VdtCameraManager.getManager();
        if (manager == null) {
            return false;
        }
//        Logger.t(TAG).d("ConnectedCamera size: " + manager.getConnectedCameras().size());

        return manager.getConnectedCameras().size() != 0;
    }

    /**
     * @param context
     * @return 判断是否有网络连接
     */
    public static boolean isNetworkConnected(Context context) {
        if (context != null) {
            // 获取手机所有连接管理对象(包括对wi-fi,net等连接的管理)
            ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
            // 获取NetworkInfo对象
            NetworkInfo networkInfo = null;
            if (manager != null) {
                networkInfo = manager.getActiveNetworkInfo();
            }
            //判断NetworkInfo对象是否为空
            if (networkInfo != null)
                return networkInfo.isAvailable();
        }
        return false;
    }

    /**
     * @param context
     * @return 判断MOBILE网络是否可用
     */
    public static boolean isMobileConnected(Context context) {
        if (context != null) {
            //获取手机所有连接管理对象(包括对wi-fi,net等连接的管理)
            ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
            //获取NetworkInfo对象
            NetworkInfo networkInfo = null;
            if (manager != null) {
                networkInfo = manager.getActiveNetworkInfo();
            }
            //判断NetworkInfo对象是否为空 并且类型是否为MOBILE
            if (networkInfo != null && networkInfo.getType() == ConnectivityManager.TYPE_MOBILE)
                return networkInfo.isAvailable();
        }
        return false;
    }

    /**
     * @param context
     * @return 获取当前的网络状态 ：没有网络-0：WIFI网络-1：4G网络-4：3G网络-3：2G网络-2
     */
    public static int getAPNType(Context context) {
        //结果返回值
        int netType = 0;
        if (context != null) {
            //获取手机所有连接管理对象
            ConnectivityManager manager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
            //获取NetworkInfo对象
            NetworkInfo networkInfo = manager != null ? manager.getActiveNetworkInfo() : null;
            //NetworkInfo对象为空 则代表没有网络
            if (networkInfo == null) {
                return netType;
            }
            //否则 NetworkInfo对象不为空 则获取该networkInfo的类型
            int nType = networkInfo.getType();
            if (nType == ConnectivityManager.TYPE_WIFI) {
                //WIFI
                netType = 1;
            } else if (nType == ConnectivityManager.TYPE_MOBILE) {
                int nSubType = networkInfo.getSubtype();
                TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);

                if (telephonyManager != null) {
                    if (nSubType == TelephonyManager.NETWORK_TYPE_LTE
                            && !telephonyManager.isNetworkRoaming()) {
                        netType = 4;
                    } else if (nSubType == TelephonyManager.NETWORK_TYPE_EVDO_A
                            || nSubType == TelephonyManager.NETWORK_TYPE_UMTS
                            || nSubType == TelephonyManager.NETWORK_TYPE_EVDO_0
                            || nSubType == TelephonyManager.NETWORK_TYPE_HSDPA
                            || nSubType == TelephonyManager.NETWORK_TYPE_HSUPA
                            || nSubType == TelephonyManager.NETWORK_TYPE_HSPA
                            || nSubType == TelephonyManager.NETWORK_TYPE_EVDO_B
                            || nSubType == TelephonyManager.NETWORK_TYPE_EHRPD
                            || nSubType == TelephonyManager.NETWORK_TYPE_HSPAP
                            && !telephonyManager.isNetworkRoaming()) {
                        netType = 3;
                    } else if (nSubType == TelephonyManager.NETWORK_TYPE_GPRS
                            || nSubType == TelephonyManager.NETWORK_TYPE_CDMA
                            || nSubType == TelephonyManager.NETWORK_TYPE_EDGE
                            || nSubType == TelephonyManager.NETWORK_TYPE_1xRTT
                            || nSubType == TelephonyManager.NETWORK_TYPE_IDEN
                            && !telephonyManager.isNetworkRoaming()) {
                        netType = 2;
                    } else {
                        netType = 2;
                    }
                }
            }
        }
        return netType;
    }

}
