package com.mkgroup.camera.message.bean;

public class MarkSettingsBean {
    /**
     * gsensorBefore : 15
     * gsensorAfter : 5
     * maxClipsForGsensor : 20
     * manualBefore : 5
     * manualAfter : 15
     */

    private int gsensorBefore;
    private int gsensorAfter;
    private int maxClipsForGsensor;
    private int manualBefore;
    private int manualAfter;

    public MarkSettingsBean(int before, int after, boolean isManual) {
        if (isManual) {
            this.manualBefore = before;
            this.manualAfter = after;
        } else {
            this.gsensorBefore = before;
            this.gsensorAfter = after;
        }
    }

    public int getGsensorBefore() {
        return gsensorBefore;
    }

    public void setGsensorBefore(int gsensorBefore) {
        this.gsensorBefore = gsensorBefore;
    }

    public int getGsensorAfter() {
        return gsensorAfter;
    }

    public void setGsensorAfter(int gsensorAfter) {
        this.gsensorAfter = gsensorAfter;
    }

    public int getMaxClipsForGsensor() {
        return maxClipsForGsensor;
    }

    public void setMaxClipsForGsensor(int maxClipsForGsensor) {
        this.maxClipsForGsensor = maxClipsForGsensor;
    }

    public int getManualBefore() {
        return manualBefore;
    }

    public void setManualBefore(int manualBefore) {
        this.manualBefore = manualBefore;
    }

    public int getManualAfter() {
        return manualAfter;
    }

    public void setManualAfter(int manualAfter) {
        this.manualAfter = manualAfter;
    }
}
