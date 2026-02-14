package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.message.bean.HotspotInfoModel;

/**
 * Created by cloud on 2021/1/16.
 */
public class HotspotInfoEvent {

    private final CameraWrapper mCameraWrapper;
    private final HotspotInfoModel mModel;

    public HotspotInfoEvent(CameraWrapper mCameraWrapper, HotspotInfoModel mModel) {
        this.mCameraWrapper = mCameraWrapper;
        this.mModel = mModel;
    }

    public CameraWrapper getCameraWrapper() {
        return mCameraWrapper;
    }

    public HotspotInfoModel getModel() {
        return mModel;
    }
}
