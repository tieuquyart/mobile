package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/6/27.
 * Email：doanvt-hn@mk.com.vn
 */

public class MountParamChangeEvent {
    private final CameraWrapper mCamera;
    private final String mountParam;

    public MountParamChangeEvent(CameraWrapper camera, String mountParam) {
        this.mCamera = camera;
        this.mountParam = mountParam;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public String getMountParam() {
        return mountParam;
    }
}
