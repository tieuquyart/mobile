package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/6/27.
 * Email：doanvt-hn@mk.com.vn
 */

public class P2PEnableChangeEvent {
    private final CameraWrapper mCamera;
    private final boolean enable;

    public P2PEnableChangeEvent(CameraWrapper camera, boolean enable) {
        this.mCamera = camera;
        this.enable = enable;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public boolean isEnable() {
        return enable;
    }
}
