package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.message.bean.MountVersion;

/**
 * Created by DoanVT on 2017/11/20.
 * Email: doanvt-hn@mk.com.vn
 */

public class MountVersionEvent {
    private final CameraWrapper mCamera;
    private final MountVersion mMountVersion;

    public MountVersionEvent(CameraWrapper camera, MountVersion mountVersion) {
        this.mCamera = camera;
        this.mMountVersion = mountVersion;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public MountVersion getMountVersion() {
        return mMountVersion;
    }
}