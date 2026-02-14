package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/5/24.
 * Email：doanvt-hn@mk.com.vn
 */

public class MicrophoneChangeEvent {
    private final CameraWrapper mCamera;
    private final int microMode;

    public MicrophoneChangeEvent(CameraWrapper camera, int microMode) {
        this.mCamera = camera;
        this.microMode = microMode;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public int getMicroMode() {
        return microMode;
    }
}
