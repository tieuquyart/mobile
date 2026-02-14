package com.mkgroup.camera.message.bean;

import java.io.Serializable;

public class TCVN03Bean implements Serializable {
    private String time;
    private String GPS;
    private String time_stop;

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getGPS() {
        return GPS;
    }

    public void setGPS(String GPS) {
        this.GPS = GPS;
    }

    public String getTime_stop() {
        return time_stop;
    }

    public void setTime_stop(String time_stop) {
        this.time_stop = time_stop;
    }
}
