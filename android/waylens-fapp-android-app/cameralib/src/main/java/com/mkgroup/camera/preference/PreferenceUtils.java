package com.mkgroup.camera.preference;

import android.content.Context;
import android.content.SharedPreferences;

import java.util.Set;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class PreferenceUtils {
    public static final String PREFERENCE = "preference";
    public static final String SERVER_URL = "server_url";
    public static final String FLEET_SERVER_URL = "fleet_server_url";
    public static final String WEB_URL = "web_url";
    public static final String KEY_SHOW_ALL_CAMERAS = "show_all_camera";
    public static final String KEY_WIFI_DIRECT_SETUP = "wifi_direct_setup";
    public static final String KEY_DOWNLOADED_FIRMWARE = "downloaded_firmware";
    public static final String KEY_LATEST_FIRMWARE_LIST = "latest_firmware_list";
    public static final String KEY_LATEST_FLEET_FIRMWARE = "latest_fleet_firmware";
    public static final String KEY_FLEET_ROLE = "fleet_role";
    public static final String KEY_FIRST_USE = "first_use";
    public static final String KEY_TOUR_GUIDE_SETUP = "tour_guide_setup";
    public static final String KEY_TOUR_GUIDE_UI = "tour_guide_ui";
    public static final String KEY_TOUR_GUIDE_DIRECT = "tour_guide_direct";
    public static final String KEY_FIRST_GUIDE_TO_VIDEO_PAGE = "first_guide_to_video_page";
    public static final String KEY_FIRST_GUIDE_TO_TOUCH = "first_guide_to_touch";
    public static final String KEY_ONCE_LOGGED_IN = "has_logged_in";
    public static final String KEY_PLAY_COOKIE_1 = "key_play_cookie1";
    public static final String KEY_PLAY_COOKIE_2 = "key_play_cookie2";
    public static final String KEY_PLAY_COOKIE_3 = "key_play_cookie3";
    public static final String SEND_FCM_TOKEN_SERVER = "send_fcm_token_server";
    public static final String ADVANCED_SETTING = "advanced_setting";
    public static final String BETA_FIRMWARE_TESTER = "beta_firmware_tester";
    public static final String ACCESS_TOB_CAMERA = "access_tob_camera";
    public static final String ACCESS_TOC_CAMERA = "access_toc_camera";
    public static final String VOICE_CALL_TEST = "voice_call_test";
    public static final String SHOW_VIDEO_QUALITY = "show_video_quality";
    public static final String SHOW_DEBUG_SETTING = "show_debug_setting";
    public static final String SYNC_VIDEO_DB = "sync_video_db";
    public static final String ENCRYPT_SP = "encrypt_sp";

    public static final String WAYLENS_TOKEN = "waylens_token";

    private static Context mSharedAppContext = null;
    private static SharedPreferences mShare = null;
    private static SharedPreferences.Editor mEditor = null;

    public static void initialize(Context context) {
        mSharedAppContext = context;
        mShare = mSharedAppContext.getSharedPreferences(PREFERENCE, Context.MODE_PRIVATE);
        mEditor = mShare.edit();
    }

    public static SharedPreferences.Editor getEditor() {
        return mEditor;
    }

    public static String getString(String key, String defValue) {
        return mShare.getString(key, defValue);
    }

    public static void putString(String key, String value) {
        mEditor.putString(key, value).apply();
    }

    public static void putInt(String key, int value) {
        mEditor.putInt(key, value).apply();
    }

    public static void putBoolean(String key, boolean value) {
        mEditor.putBoolean(key, value).apply();
    }

    public static boolean getBoolean(String key, boolean defValue) {
        return mShare.getBoolean(key, defValue);
    }

    public static Set<String> getStringSet(String key, Set<String> defValue) {
        return mShare.getStringSet(key, defValue);
    }

    public static void putStringSet(String key, Set<String> value) {
        mEditor.putStringSet(key, value);
    }

    public static void setOnceLoggedIn(boolean hasLoggedIn) {
        putBoolean(KEY_ONCE_LOGGED_IN, true);
    }

    public static boolean getOnceLoggedIn() {
        return getBoolean(KEY_ONCE_LOGGED_IN, false);
    }

    public static int getInt(String key, int defValue) {
        return mShare.getInt(key, defValue);
    }

    public static void remove(String key) {
        mEditor.remove(key).apply();
    }

    public static void clear() {
        mEditor.clear().apply();
    }

    public static void putLong(String key, long id) {
        mEditor.putLong(key, id).apply();
    }

    public static long getLong(String key, long defaultValue) {
        return mShare.getLong(key, defaultValue);
    }

}