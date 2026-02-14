package com.mkgroup.camera.message.bean;

public class P2PPairedDevicesBean {

    /**
     * device : Mac
     */

    private String device;

    public P2PPairedDevicesBean(String device) {
        this.device = device;
    }

    public String getDevice() {
        return device;
    }

    public void setDevice(String device) {
        this.device = device;
    }
}
