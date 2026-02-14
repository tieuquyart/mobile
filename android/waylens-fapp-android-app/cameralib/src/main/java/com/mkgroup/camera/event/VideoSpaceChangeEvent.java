package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/6/27.
 * Email：doanvt-hn@mk.com.vn
 */

public class VideoSpaceChangeEvent {
    private final CameraWrapper mCamera;
    private final int curSpaceIndex;

    public VideoSpaceChangeEvent(CameraWrapper camera, int curSpaceIndex) {
        this.mCamera = camera;
        this.curSpaceIndex = curSpaceIndex;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public int getCurSpaceIndex() {
        return curSpaceIndex;
    }
}
