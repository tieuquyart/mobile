package com.mkgroup.camera.model.fms;

import com.mkgroup.camera.CameraWrapper;

public class SendDataFWEvent {
    private CameraWrapper cameraWrapper;
    private SendDataFWResponse response;

    public SendDataFWEvent(CameraWrapper cameraWrapper, SendDataFWResponse response) {
        this.cameraWrapper = cameraWrapper;
        this.response = response;
    }

    public CameraWrapper getCameraWrapper() {
        return cameraWrapper;
    }

    public void setCameraWrapper(CameraWrapper cameraWrapper) {
        this.cameraWrapper = cameraWrapper;
    }

    public SendDataFWResponse getResponse() {
        return response;
    }

    public void setResponse(SendDataFWResponse response) {
        this.response = response;
    }
}
