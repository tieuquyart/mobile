package com.mkgroup.camera.message.bean;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import java.io.Serializable;
import java.util.Objects;

/**
 * Created by DoanVT on 2017/10/11.
 * Email: doanvt-hn@mk.com.vn
 */

public class MountSetting implements Serializable {
    public static String KEY_LOGO_LED = "logoLED";
    public static String KEY_NIGHT_VISION = "nightVision";
    public static String KEY_SIREN = "siren";
    public static String KEY_START_TIME = "from";
    public static String KEY_END_TIME = "to";

    public static String ON = "on";
    public static String AUTO = "auto";
    public static String OFF = "off";

    public String checksum;

    public ModeSetting parkingMode;
    public ModeSetting drivingMode;

    public String logoLED;
    public String flashLED;
    public String uploadHighlights;
    public String siren;

    public static class ModeSetting implements Serializable {
        public String monitoring;
        public String detectionSensitivity;
        public String alertSensitivity;
        public String uploadSensitivity;
        public String nightVision;
        public NightVisionTime nightVisionTime;

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            ModeSetting that = (ModeSetting) o;
            return Objects.equals(monitoring, that.monitoring) &&
                    Objects.equals(detectionSensitivity, that.detectionSensitivity) &&
                    Objects.equals(alertSensitivity, that.alertSensitivity) &&
                    Objects.equals(uploadSensitivity, that.uploadSensitivity) &&
                    Objects.equals(nightVision, that.nightVision) &&
                    Objects.equals(nightVisionTime, that.nightVisionTime);
        }

        @Override
        public int hashCode() {
            return Objects.hash(monitoring, detectionSensitivity, alertSensitivity, uploadSensitivity, nightVision, nightVisionTime);
        }

        @NonNull
        @Override
        public String toString() {
            return "ModeSetting{" +
                    "monitoring='" + monitoring + '\'' +
                    ", detectionSensitivity='" + detectionSensitivity + '\'' +
                    ", alertSensitivity='" + alertSensitivity + '\'' +
                    ", uploadSensitivity='" + uploadSensitivity + '\'' +
                    ", nightVision='" + nightVision + '\'' +
                    ", nightVisionTime=" + nightVisionTime +
                    '}';
        }
    }

    public static class NightVisionTime implements Serializable {
        //in minute
        public int from;
        public int to;

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            NightVisionTime that = (NightVisionTime) o;
            return from == that.from &&
                    to == that.to;
        }

        @Override
        public int hashCode() {
            return Objects.hash(from, to);
        }

        @NonNull
        @Override
        public String toString() {
            return "NightVisionTime{" +
                    "from=" + from +
                    ", to=" + to +
                    '}';
        }
    }

    public static boolean isOn(String item) {
        return !TextUtils.isEmpty(item) && item.equals("on");
    }

    public static String getValueString(boolean enable) {
        return enable ? ON : OFF;
    }

    public static String getValueString(int index) {
        switch (index) {
            case 1:
                return AUTO;
            case 2:
                return OFF;
            default:
                return ON;
        }
    }

    @NonNull
    @Override
    public String toString() {
        return "MountSetting{" +
                "checksum='" + checksum + '\'' +
                ", parkingMode=" + parkingMode +
                ", drivingMode=" + drivingMode +
                ", logoLED='" + logoLED + '\'' +
                ", flashLED='" + flashLED + '\'' +
                ", uploadHighlights='" + uploadHighlights + '\'' +
                ", siren='" + siren + '\'' +
                '}';
    }
}
