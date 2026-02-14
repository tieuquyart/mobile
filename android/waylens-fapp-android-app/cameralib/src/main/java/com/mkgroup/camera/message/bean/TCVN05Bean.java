package com.mkgroup.camera.message.bean;

import java.io.Serializable;

public class TCVN05Bean implements Serializable {
    private String speed_record_time;
    private int[] speed;

    public String getSpeed_record_time() {
        return speed_record_time;
    }

    public void setSpeed_record_time(String speed_record_time) {
        this.speed_record_time = speed_record_time;
    }

    public int[] getSpeed() {
        return speed;
    }

    public void setSpeed(int[] speed) {
        this.speed = speed;
    }
}
