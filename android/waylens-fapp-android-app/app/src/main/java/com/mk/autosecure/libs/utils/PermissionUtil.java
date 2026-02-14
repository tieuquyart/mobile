package com.mk.autosecure.libs.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import androidx.fragment.app.Fragment;
import androidx.core.app.NotificationManagerCompat;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.ui.DialogHelper;
import com.orhanobut.logger.Logger;

/**
 * Created by doanvt on 2018/9/10.
 * Email：doanvt-hn@mk.com.vn
 */

public class PermissionUtil {

    private final static String TAG = PermissionUtil.class.getSimpleName();

    public final static int REQUEST_APP_SETTING = 1111;

    public static void startAppSetting(Activity activity) {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        Uri uri = Uri.fromParts("package", activity.getPackageName(), null);
        intent.setData(uri);
        activity.startActivityForResult(intent, REQUEST_APP_SETTING);
    }

    public static void startAppSetting(Fragment fragment) {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        Uri uri = Uri.fromParts("package", HornApplication.getContext().getPackageName(), null);
        intent.setData(uri);
        fragment.startActivityForResult(intent, REQUEST_APP_SETTING);
    }

    public static void isNotificationEnable(Activity activity) {
        boolean enabled = NotificationManagerCompat.from(activity).areNotificationsEnabled();
        Logger.t(TAG).d("isNotificationEnable: " + enabled);
        if (!enabled) {
            DialogHelper.showNotificationDialog(activity, () -> startAppSetting(activity));
        }
    }

    public static boolean isGpsServiceEnable(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            if (context == null) {
                return false;
            }

            LocationManager locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
            if (locationManager == null) {
                Logger.t(TAG).e("locationManager == null");
                return false;
            }
            boolean locationEnabled = locationManager.isLocationEnabled();
            Logger.t(TAG).d("locationEnabled: " + locationEnabled);
            return locationEnabled;
        }
        // P以下不考虑Gps service
        return true;
    }

}
