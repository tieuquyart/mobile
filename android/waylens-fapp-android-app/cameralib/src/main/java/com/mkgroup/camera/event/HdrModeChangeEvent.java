package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by DoanVT on 2017/11/20.
 * Email: doanvt-hn@mk.com.vn
 */

public class HdrModeChangeEvent {
    private final CameraWrapper mCamera;
    private final int hdrMode;

    public HdrModeChangeEvent(CameraWrapper camera, int hdrMode) {
        this.mCamera = camera;
        this.hdrMode = hdrMode;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public int getHdrMode() {
        return hdrMode;
    }
}


