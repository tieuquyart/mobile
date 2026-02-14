package com.mk.autosecure.libs.utils;

import com.mkgroup.camera.preference.PreferenceUtils;

/**
 * Created by DoanVT on 2017/11/24.
 * Email: doanvt-hn@mk.com.vn
 */

public class DebugHelper {

    private static final String DEBUG_MODE = "debug.mode";

    public static boolean isInDebugMode() {
        return PreferenceUtils.getBoolean(DEBUG_MODE, false);
    }

    public static void setDebugMode(boolean debugMode) {
        PreferenceUtils.putBoolean(DEBUG_MODE, debugMode);
    }
}
