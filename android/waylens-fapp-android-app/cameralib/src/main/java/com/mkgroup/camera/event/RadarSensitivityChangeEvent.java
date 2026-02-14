package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/6/27.
 * Email：doanvt-hn@mk.com.vn
 */
public class RadarSensitivityChangeEvent {
    private final CameraWrapper mCamera;
    private final int sensitivity;

    public RadarSensitivityChangeEvent(CameraWrapper camera, int sensitivity) {
        this.mCamera = camera;
        this.sensitivity = sensitivity;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public int getSensitivity() {
        return sensitivity;
    }
}
