package com.mk.autosecure.uploadqueue.utils;

import com.mkgroup.camera.preference.PreferenceUtils;

import java.util.Arrays;

/**
 * Created by doanvt on 2016/11/11.
 */

public class SettingHelper {

    private static final String UNITS = "units";
    public static final String METRIC_UNIT = "metric";
    public static final String US_UNIT = "US";
    public static final String IMPERIAL_UNIT = "imperial";

    public static String[] unitList = {METRIC_UNIT, US_UNIT, IMPERIAL_UNIT};

    public static String getUnit() {
        return PreferenceUtils.getString(SettingHelper.UNITS, US_UNIT);
    }

    public static int getUnitIndex() {
        return Arrays.asList(unitList).indexOf(getUnit());
    }

    public static boolean isMetricUnit() {
        return getUnit().equals(METRIC_UNIT);
    }

    public static void setMetricUnit(boolean isMetricUnit) {

    }

    public static void setUnit(String unitType) {
        switch (unitType) {
            case US_UNIT:

            case METRIC_UNIT:

            case IMPERIAL_UNIT:
                PreferenceUtils.putString(SettingHelper.UNITS, unitType);
                break;
            default:
                break;
        }
    }
}
