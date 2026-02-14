package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/6/27.
 * Email：doanvt-hn@mk.com.vn
 */

public class MountAccTrustChangeEvent {
    private final CameraWrapper mCamera;
    private final int mAcctrust;

    public MountAccTrustChangeEvent(CameraWrapper camera, int mAcctrust) {
        this.mCamera = camera;
        this.mAcctrust = mAcctrust;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public int getAcctrust() {
        return mAcctrust;
    }
}
