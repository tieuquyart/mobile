package com.mkgroup.camera.bean;

import java.io.Serializable;
import java.util.Objects;

/**
 * Created by DoanVT on 2017/9/18.
 */

public class CameraState implements Serializable {

    public final static String DRIVING_MODE = "driving";

    public String firmware;
    public String firmwareShort;

    public MountInfo mountInfo;

    public String modem;
    public String poweredBy;
    public String engineStatus;
    public boolean batteryCharging;
    public int batteryRemaining;
    public int batteryVol;
    public String mode;
    public boolean online;

    @Override
    public String toString() {
        return "CameraState{" +
                "firmware='" + firmware + '\'' +
                ", firmwareShort='" + firmwareShort + '\'' +
                ", mountInfo=" + mountInfo +
                ", modem='" + modem + '\'' +
                ", engineStatus='" + engineStatus + '\'' +
                ", poweredBy='" + poweredBy + '\'' +
                ", batteryCharging=" + batteryCharging +
                ", batteryRemaining=" + batteryRemaining +
                ", batteryVol=" + batteryVol +
                ", mode='" + mode + '\'' +
                ", online=" + online +
                ", offlineReason='" + offlineReason + '\'' +
                ", gpsStatus='" + gpsStatus + '\'' +
                ", gps=" + gps +
                ", obdStatus='" + obdStatus + '\'' +
                ", remoteControlStatus='" + remoteControlStatus + '\'' +
                ", sdCardStatus='" + sdCardStatus + '\'' +
                ", sdCardUsage=" + sdCardUsage +
                ", errors='" + errors + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CameraState that = (CameraState) o;
        return batteryCharging == that.batteryCharging &&
                batteryRemaining == that.batteryRemaining &&
                batteryVol == that.batteryVol &&
                online == that.online &&
                Objects.equals(firmware, that.firmware) &&
                Objects.equals(firmwareShort, that.firmwareShort) &&
                Objects.equals(mountInfo, that.mountInfo) &&
                Objects.equals(modem, that.modem) &&
                Objects.equals(engineStatus, that.engineStatus) &&
                Objects.equals(poweredBy, that.poweredBy) &&
                Objects.equals(mode, that.mode) &&
                Objects.equals(offlineReason, that.offlineReason) &&
                Objects.equals(gpsStatus, that.gpsStatus) &&
                Objects.equals(gps, that.gps) &&
                Objects.equals(obdStatus, that.obdStatus) &&
                Objects.equals(remoteControlStatus, that.remoteControlStatus) &&
                Objects.equals(sdCardStatus, that.sdCardStatus) &&
                Objects.equals(sdCardUsage, that.sdCardUsage) &&
                Objects.equals(errors, that.errors);
    }

    @Override
    public int hashCode() {
        return Objects.hash(firmware, firmwareShort, mountInfo, modem, engineStatus, poweredBy, batteryCharging, batteryRemaining, batteryVol, mode, online, offlineReason, gpsStatus, gps, obdStatus, remoteControlStatus, sdCardStatus, sdCardUsage, errors);
    }

    public String offlineReason;
    public String gpsStatus;

    public Alert.GPS gps;

    public String obdStatus;
    public String remoteControlStatus;
    public String sdCardStatus;

    public SDCardUsage sdCardUsage;

    public String errors;

    public static class SDCardUsage implements Serializable {
        public long size;
        public long usedForBuffered;
        public long usedForHighlights;

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            SDCardUsage that = (SDCardUsage) o;
            return size == that.size &&
                    usedForBuffered == that.usedForBuffered &&
                    usedForHighlights == that.usedForHighlights;
        }

        @Override
        public int hashCode() {
            return Objects.hash(size, usedForBuffered, usedForHighlights);
        }

        @Override
        public String toString() {
            return "SDCardUsage{" +
                    "size=" + size +
                    ", usedForBuffered=" + usedForBuffered +
                    ", usedForHighlights=" + usedForHighlights +
                    '}';
        }
    }

    public static class MountInfo implements Serializable {
        public String mountHWVersion;
        public String mountFWVersion;
        public boolean mount4G;

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            MountInfo mountInfo = (MountInfo) o;
            return mount4G == mountInfo.mount4G &&
                    longLived == mountInfo.longLived &&
                    Objects.equals(mountHWVersion, mountInfo.mountHWVersion) &&
                    Objects.equals(mountFWVersion, mountInfo.mountFWVersion);
        }

        @Override
        public int hashCode() {
            return Objects.hash(mountHWVersion, mountFWVersion, mount4G, longLived);
        }

        public boolean longLived;

        @Override
        public String toString() {
            return "MountInfo{" +
                    "mountHWVersion='" + mountHWVersion + '\'' +
                    ", mountFWVersion='" + mountFWVersion + '\'' +
                    ", mount4G=" + mount4G +
                    ", longLived=" + longLived +
                    '}';
        }
    }

}
