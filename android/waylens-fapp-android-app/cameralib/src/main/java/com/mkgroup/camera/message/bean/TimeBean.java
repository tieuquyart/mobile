package com.mkgroup.camera.message.bean;

public class TimeBean {

    /**
     * time : 1582702359
     * time_us : 809398
     * gmtoff : -28800
     */

    private long time;
    private long time_us;
    private long gmtoff;

    public TimeBean(long time, long gmtoff) {
        this.time = time;
        this.gmtoff = gmtoff;
    }

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public long getTime_us() {
        return time_us;
    }

    public void setTime_us(long time_us) {
        this.time_us = time_us;
    }

    public long getGmtoff() {
        return gmtoff;
    }

    public void setGmtoff(long gmtoff) {
        this.gmtoff = gmtoff;
    }

}
