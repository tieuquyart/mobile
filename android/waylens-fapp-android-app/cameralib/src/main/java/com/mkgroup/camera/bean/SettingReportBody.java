package com.mkgroup.camera.bean;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.message.bean.MountSetting;
import com.orhanobut.logger.Logger;

import java.io.Serializable;
import java.util.Objects;

import static com.mkgroup.camera.model.Clip.LENS_NORMAL;
import static com.mkgroup.camera.model.Clip.LENS_UPSIDEDOWN;


/**
 * Created by DoanVT on 2017/12/19.
 * Email: doanvt-hn@mk.com.vn
 */
public class SettingReportBody {

    private final static String TAG = SettingReportBody.class.getSimpleName();

    public String hardwareVersion;

    public CameraVersion version;

    public Setting settings;

    public CameraState state;

    public String rotate;

    @Override
    public String toString() {
        return "SettingReportBody{" +
                "hardwareVersion='" + hardwareVersion + '\'' +
                ", version=" + version +
                ", settings=" + settings +
                ", state=" + state +
                ", rotate='" + rotate + '\'' +
                '}';
    }

    public static class CameraVersion implements Serializable {
        public String firmware;
        public String api;
        public Mount mount;

        @Override
        public String toString() {
            return "CameraVersion{" +
                    "firmware='" + firmware + '\'' +
                    ", api='" + api + '\'' +
                    ", mount=" + mount +
                    '}';
        }
    }

    public static class Mount implements Serializable {
        public String HW;
        public String FW;
        public boolean is4G;

        @Override
        public String toString() {
            return "Mount{" +
                    "HW='" + HW + '\'' +
                    ", FW='" + FW + '\'' +
                    ", is4G=" + is4G +
                    '}';
        }
    }

    public static class Setting implements Serializable {
        public String checksum;

        public MountSetting.ModeSetting parkingMode;

        public MountSetting.ModeSetting drivingMode;

        public String logoLED;
        public String flashLED;
        public String uploadHighlights;
        public String siren;

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            Setting setting = (Setting) o;
            return Objects.equals(checksum, setting.checksum) &&
                    Objects.equals(parkingMode, setting.parkingMode) &&
                    Objects.equals(drivingMode, setting.drivingMode) &&
                    Objects.equals(logoLED, setting.logoLED) &&
                    Objects.equals(flashLED, setting.flashLED) &&
                    Objects.equals(uploadHighlights, setting.uploadHighlights) &&
                    Objects.equals(siren, setting.siren);
        }

        @Override
        public int hashCode() {
            return Objects.hash(checksum, parkingMode, drivingMode, logoLED, flashLED, uploadHighlights, siren);
        }

        @Override
        public String toString() {
            return "Setting{" +
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

    public static SettingReportBody makeBody(CameraWrapper camera, CameraBean remoteCamera) {
        if (remoteCamera == null) {
            return null;
        }

        SettingReportBody body = new SettingReportBody();

        boolean supportUpsidedown = camera.getSupportUpsidedown();
        if (supportUpsidedown) {
            body.rotate = camera.getIsLensNormal() ? LENS_NORMAL : LENS_UPSIDEDOWN;
        }

        //这里的hardwareVersion其实是hardwareModel，如SC_V0D
        body.hardwareVersion = camera.getHardwareName();

        Logger.t(TAG).d("vdtCamera checksum: " + camera.getMountSettings(false).checksum);

        if (remoteCamera.settings != null
                && !remoteCamera.settings.checksum.equals(camera.getMountSettings(false).checksum)) {
            body.settings = new Setting();
            MountSetting mountSetting = camera.getMountSettings(false);

            body.settings.checksum = mountSetting.checksum;

            if (mountSetting.parkingMode != null) {
                body.settings.parkingMode = mountSetting.parkingMode;
            }
            if (mountSetting.drivingMode != null) {
                body.settings.drivingMode = mountSetting.drivingMode;
            }

            body.settings.logoLED = MountSetting.getValueString(MountSetting.isOn(mountSetting.logoLED));
            body.settings.flashLED = MountSetting.getValueString(MountSetting.isOn(mountSetting.flashLED));
            body.settings.siren = MountSetting.getValueString(MountSetting.isOn(mountSetting.siren));
            body.settings.uploadHighlights = MountSetting.getValueString(MountSetting.isOn(mountSetting.uploadHighlights));
        }
        return body;
    }

    public static class CameraState implements Serializable {
        public int timezone;
        public String mode;
        public String monitoring;
        public String engineStatus;
        public String poweredBy;
        public boolean batteryCharging;
        public int batteryRemaining;
        public String gps;
        public String obd;
        public String remoteControl;
        public String sdCard;
        public com.mkgroup.camera.bean.CameraState.SDCardUsage sdCardUsage;
        public String errors;
    }

}
