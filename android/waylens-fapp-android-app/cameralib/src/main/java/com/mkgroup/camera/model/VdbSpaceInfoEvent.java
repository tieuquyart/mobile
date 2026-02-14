package com.mkgroup.camera.model;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by DoanVT on 2017/12/1.
 * Email: doanvt-hn@mk.com.vn
 */

public class VdbSpaceInfoEvent {

    private final CameraWrapper mCamera;
    private final SpaceInfo spaceInfo;

    public VdbSpaceInfoEvent(CameraWrapper camera, SpaceInfo spaceInfo) {
        this.mCamera = camera;
        this.spaceInfo = spaceInfo;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public SpaceInfo getExtra() {
        return spaceInfo;
    }
}
