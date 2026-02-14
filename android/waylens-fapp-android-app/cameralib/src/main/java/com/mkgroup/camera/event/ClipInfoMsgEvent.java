package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.model.ClipActionInfo;

/**
 * Created by laina on 17/2/9.
 */
public class ClipInfoMsgEvent {
    private final CameraWrapper mCamera;
    private final ClipActionInfo mClipActionInfo;

    public ClipInfoMsgEvent(CameraWrapper camera, ClipActionInfo mClipActionInfo) {
        this.mCamera = camera;
        this.mClipActionInfo = mClipActionInfo;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public ClipActionInfo getClipActionInfo() {
        return mClipActionInfo;
    }
}
