package com.mk.autosecure.rest.request;

import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.SettingReportBody;
import com.mkgroup.camera.message.bean.MountSetting;

import java.io.Serializable;

/**
 * Created by doanvt on 2018/7/16.
 * Email：doanvt-hn@mk.com.vn
 */

public class CameraControlBody {
    public SettingReportBody.Setting settings;

    public CameraActions actions;

    class CameraActions implements Serializable{
        public String monitoring;
    }

    @Override
    public String toString() {
        return "CameraControlBody{" +
                "settings=" + settings +
                ", actions=" + actions +
                '}';
    }

    public static CameraControlBody makeBody(CameraBean cameraBean) {
        CameraControlBody body = new CameraControlBody();

        body.settings = new SettingReportBody.Setting();

        SettingReportBody.Setting settings = cameraBean.settings;

        body.settings.parkingMode = settings.parkingMode;
        body.settings.drivingMode = settings.drivingMode;

        body.settings.logoLED = MountSetting.getValueString(MountSetting.isOn(settings.logoLED));
        body.settings.flashLED = MountSetting.getValueString(MountSetting.isOn(settings.flashLED));
        body.settings.siren = MountSetting.getValueString(MountSetting.isOn(settings.siren));
        body.settings.uploadHighlights = MountSetting.getValueString(MountSetting.isOn(settings.uploadHighlights));

        return body;
    }
}
