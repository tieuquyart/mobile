package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2018/5/24.
 * Email：doanvt-hn@mk.com.vn
 */

public class AudioPromptsChangeEvent {
    private final CameraWrapper mCamera;
    private final int promptsMode;

    public AudioPromptsChangeEvent(CameraWrapper camera, int promptsMode) {
        this.mCamera = camera;
        this.promptsMode = promptsMode;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public int getPromptsMode() {
        return promptsMode;
    }
}
