package com.mkgroup.camera.message.bean;

import java.io.Serializable;

public class TCVN04Bean implements Serializable {
    private String cur_time;
    private String GPS;
    private String speed;

    public String getCur_time() {
        return cur_time;
    }

    public void setCur_time(String cur_time) {
        this.cur_time = cur_time;
    }

    public String getGPS() {
        return GPS;
    }

    public void setGPS(String GPS) {
        this.GPS = GPS;
    }

    public String getSpeed() {
        return speed;
    }

    public void setSpeed(String speed) {
        this.speed = speed;
    }
}
