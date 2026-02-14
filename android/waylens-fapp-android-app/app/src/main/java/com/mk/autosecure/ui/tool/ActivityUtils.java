package com.mk.autosecure.ui.tool;

import android.app.Activity;

import com.mkgroup.camera.preference.PreferenceUtils;
import com.mk.autosecure.libs.utils.Constants;
import com.mk.autosecure.ui.activity.LoginActivity;
import com.mk.autosecure.ui.activity.SignUpActivity;

/**
 * Created by DoanVT on 2018/2/1.
 * Email: doanvt-hn@mk.com.vn
 */

public class ActivityUtils {


    public static void toAuthorization(Activity activity) {
        if (PreferenceUtils.getOnceLoggedIn() || Constants.isFleet()) {
            LoginActivity.launch(activity);
        } else {
            SignUpActivity.launch(activity);
        }
    }
}
