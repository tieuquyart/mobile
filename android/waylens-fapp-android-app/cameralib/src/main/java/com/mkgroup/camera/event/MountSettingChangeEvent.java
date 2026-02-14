package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.message.bean.MountSetting;

/**
 * Created by DoanVT on 2017/10/11.
 * Email: doanvt-hn@mk.com.vn
 */

public class MountSettingChangeEvent {
    private final CameraWrapper mCamera;
    private final MountSetting mMountSetting;

    public MountSettingChangeEvent(CameraWrapper camera, MountSetting mountSetting) {
        this.mCamera = camera;
        this.mMountSetting = mountSetting;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public MountSetting getMountSetting() {
        return mMountSetting;
    }
}
