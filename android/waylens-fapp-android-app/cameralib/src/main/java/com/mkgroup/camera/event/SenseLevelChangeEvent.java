package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/6/27.
 * Email：doanvt-hn@mk.com.vn
 */
public class SenseLevelChangeEvent {
    private final CameraWrapper mCamera;
    private final int curLevelIndex;

    public SenseLevelChangeEvent(CameraWrapper camera, int curLevelIndex) {
        this.mCamera = camera;
        this.curLevelIndex = curLevelIndex;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public int getCurLevelIndex() {
        return curLevelIndex;
    }
}
