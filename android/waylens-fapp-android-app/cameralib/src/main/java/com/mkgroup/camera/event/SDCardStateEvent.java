package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/8/24.
 * Email：doanvt-hn@mk.com.vn
 */
public class SDCardStateEvent {

    private final int state;
    private final CameraWrapper mCamera;

    public SDCardStateEvent(int what, CameraWrapper camera) {
        this.state = what;
        this.mCamera = camera;
    }

    public int getState() {
        return state;
    }

    public CameraWrapper getVdtCamera() {
        return mCamera;
    }
}
