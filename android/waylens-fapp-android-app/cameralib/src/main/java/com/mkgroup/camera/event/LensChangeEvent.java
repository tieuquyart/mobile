package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/6/27.
 * Email：doanvt-hn@mk.com.vn
 */

public class LensChangeEvent {
    private final CameraWrapper mCamera;
    private final boolean mIsLensNormal;

    public LensChangeEvent(CameraWrapper camera, boolean isLensNormal) {
        this.mCamera = camera;
        this.mIsLensNormal = isLensNormal;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public boolean isLensNormal() {
        return mIsLensNormal;
    }

}
