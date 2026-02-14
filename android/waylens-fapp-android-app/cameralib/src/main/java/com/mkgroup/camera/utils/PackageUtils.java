package com.mkgroup.camera.utils;

import android.content.Context;

public class PackageUtils {

    private final static String TAG = PackageUtils.class.getSimpleName();

    public static boolean isFirstInstall(Context context) {
        return getPackageFirstInstallTime(context) == getPackageLastUpdateTime(context);
    }

    private static long getPackageFirstInstallTime(Context context) {
        String name = context.getPackageName();
        long time = 0;
        try {
            time = context.getPackageManager().getPackageInfo(name, 0).firstInstallTime;
//            Logger.t(TAG).e("getPackageFirstInstallTime: " + time);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return time;
    }

    private static long getPackageLastUpdateTime(Context context) {
        String name = context.getPackageName();
        long time = 0;
        try {
            time = context.getPackageManager().getPackageInfo(name, 0).lastUpdateTime;
//            Logger.t(TAG).e("getPackageLastUpdateTime: " + time);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return time;
    }
}
