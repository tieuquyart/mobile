package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/6/27.
 * Email：doanvt-hn@mk.com.vn
 */

public class VideoQualityChangeEvent {
    private final CameraWrapper mCamera;
    private final int mainQualityIndex;
    private final int subQualityIndex;

    public VideoQualityChangeEvent(CameraWrapper camera, int mainQualityIndex, int subQualityIndex) {
        this.mCamera = camera;
        this.mainQualityIndex = mainQualityIndex;
        this.subQualityIndex = subQualityIndex;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public int getMainQualityIndex() {
        return mainQualityIndex;
    }

    public int getSubQualityIndex() {
        return subQualityIndex;
    }
}
