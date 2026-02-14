package com.mk.autosecure.libs.utils;

import com.mkgroup.camera.preference.PreferenceUtils;
import com.mk.autosecure.BuildConfig;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class Constants {
    private static String STAGING_BASE_URL = "";
    private static String ALIYUN_BASE_URL = "";
    private static String BASE_URL = "";

    public static final String HORN = "horn";
    public static final String FLEET = "autosecure";

    public static final String FLEET_ROLE_MANAGER = "FleetManager";
    public static final String FLEET_ROLE_DRIVER = "Driver";
    public static final String FLEET_ROLE_INSTALLER = "Installer";

    public static final String FLEET_ROLE_ADMIN = "admin";
    public static final String FLEET_ROLE_USER = "user";

    public static final String AUTOSECURE_ROLES = "autosecure_roles";
    public static final String KEY_IS_LOGIN = "key_is_login";
    public static final String KEY_SHOW_UPDATE = "key_is_show_update";

    public static final String KEY_PUSH_CHANNEL = "key_is_show_update";

    public static boolean isFleet() {
        String flavorName = BuildConfig.FLAVOR_NAME;
        return FLEET.equals(flavorName);
    }

    public static boolean has_push_notification = false;

    public static boolean isAdmin() {
        String role = PreferenceUtils.getString(PreferenceUtils.KEY_FLEET_ROLE, isFleet() ? FLEET_ROLE_ADMIN : "");
        return FLEET_ROLE_ADMIN.equals(role);
    }

    public static String getRole() {
        String role = PreferenceUtils.getString(AUTOSECURE_ROLES, "admin");
        return role;
    }

    public static boolean isUser() {
        String role = PreferenceUtils.getString(PreferenceUtils.KEY_FLEET_ROLE, isFleet() ? FLEET_ROLE_USER : "");
        return FLEET_ROLE_USER.equals(role);
    }

    public static boolean isManager() {
        String role = PreferenceUtils.getString(PreferenceUtils.KEY_FLEET_ROLE, isFleet() ? FLEET_ROLE_DRIVER : "");
        return FLEET_ROLE_MANAGER.equals(role);
    }

//    public static boolean isDriver() {
//        String role = PreferenceUtils.getString(PreferenceUtils.KEY_FLEET_ROLE, isFleet() ? FLEET_ROLE_DRIVER : "");
//        return FLEET_ROLE_DRIVER.equals(role);
//    }

//    public static boolean isInstaller() {
//        String role = PreferenceUtils.getString(PreferenceUtils.KEY_FLEET_ROLE, isFleet() ? FLEET_ROLE_DRIVER : "");
//        return FLEET_ROLE_INSTALLER.equals(role);
//    }
    public static boolean isLogin(){
        boolean isLogin =  PreferenceUtils.getBoolean(KEY_IS_LOGIN, false);
        return isLogin;
    }

    public static boolean isShowUpdate(){
        return PreferenceUtils.getBoolean(KEY_SHOW_UPDATE,false);
    }
}
