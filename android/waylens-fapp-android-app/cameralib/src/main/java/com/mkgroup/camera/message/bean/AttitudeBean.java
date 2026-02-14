package com.mkgroup.camera.message.bean;

public class AttitudeBean {

    /**
     * isConfigurable : true
     * attitude : normal
     */

    private boolean isConfigurable;
    private String attitude;

    public AttitudeBean(String attitude) {
        this.attitude = attitude;
    }

    public boolean isIsConfigurable() {
        return isConfigurable;
    }

    public void setIsConfigurable(boolean isConfigurable) {
        this.isConfigurable = isConfigurable;
    }

    public String getAttitude() {
        return attitude;
    }

    public void setAttitude(String attitude) {
        this.attitude = attitude;
    }
}
