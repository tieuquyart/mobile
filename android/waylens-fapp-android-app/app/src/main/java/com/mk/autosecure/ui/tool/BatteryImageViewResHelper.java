package com.mk.autosecure.ui.tool;

import androidx.annotation.DrawableRes;

import com.mkgroup.camera.VdtCamera;
import com.mk.autosecure.R;

/**
 * Created by DoanVT on 2017/11/29.
 * Email: doanvt-hn@mk.com.vn
 */

public class BatteryImageViewResHelper {
    private static final int NONE_RES = -1;
    private BatteryImageViewResHelper() {

    }

    public static @DrawableRes
    int getBatteryViewWhiteRes(int level, int state, int voltage) {
        /*
        if (voltage > VdtCamera.BATTERY_VOLTAGE_CRITERIA && state == VdtCamera.STATE_BATTERY_CHARGING) {
            return R.drawable.icon_2charging_wh;
        }
        */
        if (state == VdtCamera.STATE_BATTERY_CHARGING) {
            return -1;
            /*
            switch (level) {
                case VdtCamera.BATTERY_CAPACITY_LEVEL_CRITICAL:
                    return R.drawable.icon_charging_wh4;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_LOW:
                    return R.drawable.icon_charging_wh4;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_NORMAL:
                    return R.drawable.icon_charging_wh3;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_HIGH:
                    return R.drawable.icon_charging_wh2;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_FULL:
                    return R.drawable.icon_charging_wh1;
                default:
                    return R.drawable.icon_charging_wh1;
            }
            */
        } else {
            switch (level) {
                case VdtCamera.BATTERY_CAPACITY_LEVEL_CRITICAL:
                    return R.drawable.icon_battery_white_4;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_LOW:
                    return R.drawable.icon_battery_white_4;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_NORMAL:
                    return R.drawable.icon_battery_white_3;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_HIGH:
                    return R.drawable.icon_battery_white_2;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_FULL:
                    return NONE_RES;
                default:
                    return NONE_RES;
            }
        }
    }

    public static @DrawableRes
    int getBatteryViewRes(int level, int state, int voltage) {
        if (voltage > VdtCamera.BATTERY_VOLTAGE_CRITERIA && state == VdtCamera.STATE_BATTERY_CHARGING) {
            return R.drawable.icon_2charging;
        }
        if (state == VdtCamera.STATE_BATTERY_CHARGING) {
            switch (level) {
                case VdtCamera.BATTERY_CAPACITY_LEVEL_CRITICAL:
                    return R.drawable.icon_charging4;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_LOW:
                    return R.drawable.icon_charging4;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_NORMAL:
                    return R.drawable.icon_charging3;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_HIGH:
                    return R.drawable.icon_charging2;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_FULL:
                    return R.drawable.icon_charging1;
                default:
                    return R.drawable.icon_charging1;
            }
        } else {
            switch (level) {
                case VdtCamera.BATTERY_CAPACITY_LEVEL_CRITICAL:
                    return R.drawable.icon_battery_4;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_LOW:
                    return R.drawable.icon_battery_4;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_NORMAL:
                    return R.drawable.icon_battery_3;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_HIGH:
                    return R.drawable.icon_battery_2;
                case VdtCamera.BATTERY_CAPACITY_LEVEL_FULL:
                    return R.drawable.icon_battery_1;
                default:
                    return R.drawable.icon_battery_1;
            }
        }
    }
}
