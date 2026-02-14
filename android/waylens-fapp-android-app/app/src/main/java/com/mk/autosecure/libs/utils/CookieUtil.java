package com.mk.autosecure.libs.utils;

import android.text.TextUtils;

import com.mkgroup.camera.preference.PreferenceUtils;

import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by doanvt on 2018/7/16.
 * Email：doanvt-hn@mk.com.vn
 */

public class CookieUtil {

    private final static String TAG = CookieUtil.class.getSimpleName();

    public static void setCookie(List<String> values) {
        PreferenceUtils.putString(PreferenceUtils.KEY_PLAY_COOKIE_1, values.get(0));
        PreferenceUtils.putString(PreferenceUtils.KEY_PLAY_COOKIE_2, values.get(1));
        PreferenceUtils.putString(PreferenceUtils.KEY_PLAY_COOKIE_3, values.get(2));
//        Logger.t(TAG).e("setCookie: " + values);
    }

    public static Map<String, String> getCookie() {
        String cookie1 = PreferenceUtils.getString(PreferenceUtils.KEY_PLAY_COOKIE_1, "");
        String cookie2 = PreferenceUtils.getString(PreferenceUtils.KEY_PLAY_COOKIE_2, "");
        String cookie3 = PreferenceUtils.getString(PreferenceUtils.KEY_PLAY_COOKIE_3, "");

        Map<String, String> cookieMap = new IdentityHashMap<>();

        if (TextUtils.isEmpty(cookie1) || TextUtils.isEmpty(cookie2) || TextUtils.isEmpty(cookie3)) {
            return cookieMap;
        }

        cookieMap.put(new String("Cookie"), cookie1);
        cookieMap.put(new String("Cookie"), cookie2);
        cookieMap.put(new String("Cookie"), cookie3);

//        Logger.t(TAG).e("getCookie: " + cookieMap.toString());
        return cookieMap;
    }

}
