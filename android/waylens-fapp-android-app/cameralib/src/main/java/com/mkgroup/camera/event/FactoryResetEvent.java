package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by DoanVT on 2017/11/21.
 * Email: doanvt-hn@mk.com.vn
 */

public class FactoryResetEvent {

    private enum Result {success, failed}

    private final CameraWrapper mCamera;
    private final Result res;

    public FactoryResetEvent(CameraWrapper camera, int res) {
        this.mCamera = camera;
        this.res = res > 0 ? Result.success : Result.failed;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public boolean getResult() {
        return this.res == Result.success;
    }
}