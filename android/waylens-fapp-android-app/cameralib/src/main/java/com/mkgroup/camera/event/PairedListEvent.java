package com.mkgroup.camera.event;


import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.direct.PairedDevices;

/**
 * Created by doanvt on 2019/3/14.
 * Email：doanvt-hn@mk.com.vn
 */
public class PairedListEvent {

    private final PairedDevices devices;
    private final CameraWrapper mCamera;

    public PairedListEvent(PairedDevices devices, CameraWrapper camera) {
        this.devices = devices;
        this.mCamera = camera;
    }

    public PairedDevices getDevices() {
        return devices;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }
}
