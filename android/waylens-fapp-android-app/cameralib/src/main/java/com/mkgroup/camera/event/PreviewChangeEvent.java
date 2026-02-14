package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;

public class PreviewChangeEvent {

    private CameraWrapper cameraWrapper;

    private CameraBean cameraBean;

    private FleetCameraBean fleetCameraBean;

    public PreviewChangeEvent(CameraWrapper cameraWrapper) {
        this.cameraWrapper = cameraWrapper;
    }

    public PreviewChangeEvent(CameraBean cameraBean) {
        this.cameraBean = cameraBean;
    }

    public PreviewChangeEvent(FleetCameraBean fleetCameraBean) {
        this.fleetCameraBean = fleetCameraBean;
    }

    public CameraWrapper getCamera() {
        return cameraWrapper;
    }

    public CameraBean getCameraBean() {
        return cameraBean;
    }

    public FleetCameraBean getFleetCameraBean() {
        return fleetCameraBean;
    }
}
