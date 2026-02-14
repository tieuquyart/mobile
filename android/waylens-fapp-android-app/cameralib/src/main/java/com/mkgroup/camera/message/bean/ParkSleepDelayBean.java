package com.mkgroup.camera.message.bean;

public class ParkSleepDelayBean {

    /**
     * delayInSec : 3600
     */

    private int delayInSec;

    public ParkSleepDelayBean(int delayInSec) {
        this.delayInSec = delayInSec;
    }

    public int getDelayInSec() {
        return delayInSec;
    }

    public void setDelayInSec(int delayInSec) {
        this.delayInSec = delayInSec;
    }
}
