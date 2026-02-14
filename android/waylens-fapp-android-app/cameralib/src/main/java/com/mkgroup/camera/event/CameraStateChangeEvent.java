package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

/**
 * Created by doanvt on 2016/4/19.
 */
public class CameraStateChangeEvent {
    private final int mWhat;
    private final CameraWrapper mCamera;
    private final Object mExtra;

    public static final int CAMERA_STATE_INFO = 0;
    public static final int CAMERA_STATE_REC = 1;
    public static final int CAMERA_STATE_REC_DURATION = 2;
    public static final int CAMERA_STATE_REC_ERROR = 3;
    public static final int CAMERA_STATE_BT_DEVICE_STATUS_CHANGED = 4;
    public static final int CAMERA_STATE_MICROPHONE_STATUS_CHANGED = 5;
    public static final int CAMERA_STATE_REC_ROTATE = 6;
    public static final int CAMERA_STATE_MONITOR_MODE = 7;


    public CameraStateChangeEvent(int what, CameraWrapper camera) {
        this(what, camera, null);
    }

    public CameraStateChangeEvent(int what, CameraWrapper camera, Object extra) {
        this.mWhat = what;
        this.mCamera = camera;
        this.mExtra = extra;
    }

    public int getWhat() {
        return mWhat;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public Object getExtra() {
        return mExtra;
    }
}
