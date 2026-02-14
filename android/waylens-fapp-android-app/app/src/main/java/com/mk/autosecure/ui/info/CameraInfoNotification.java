package com.mk.autosecure.ui.info;

/**
 * Created by DoanVT on 2017/12/2 9.
 * Email: doanvt-hn@mk.com.vn
 */

public class CameraInfoNotification {

    public enum NotiLevel {
        ERROR,
        WARNINGS,
        INFORMATION
    }

    public enum NotiType {
        ERROR_SDCARD_ERROR,
        ERROR_SDCARD_NOT_DETECTED,
        ERROR_RECORD_ERROR,
        WARNING_SDCARD_LOW_CAPACITY,
        INFO_RECORD_STOPPED
    }
}
