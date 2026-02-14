package com.mkgroup.camera.event;


import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.model.ClipActionInfo;

/**
 * Created by DoanVT on 16/7/4.
 */
public class MarkLiveMsgEvent {
    private final CameraWrapper mCamera;
    private final ClipActionInfo mClipActionInfo;
    private final boolean mMarkLiveState;

    public MarkLiveMsgEvent(CameraWrapper camera, ClipActionInfo mClipActionInfo, boolean markLive) {
        this.mCamera = camera;
        this.mClipActionInfo = mClipActionInfo;
        this.mMarkLiveState = markLive;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public ClipActionInfo getClipActionInfo() {
        return mClipActionInfo;
    }

    public boolean getMarkLiveState() {
        return mMarkLiveState;
    }
}
