package com.mk.autosecure.model;

import java.io.Serializable;

/**
 * Created by doanvt on 2022/11/02.
 */
public class LogSpeedWithTimeBean implements Serializable {
    private String dateTime;
    private String lat;
    private String log;
    private String[] speed;

    public LogSpeedWithTimeBean(String dateTime, String lat, String log, String[] speed) {
        this.dateTime = dateTime;
        this.lat = lat;
        this.log = log;
        this.speed = speed;
    }

    public String getDateTime() {
        return dateTime;
    }

    public void setDateTime(String dateTime) {
        this.dateTime = dateTime;
    }

    public String getLat() {
        return lat;
    }

    public void setLat(String lat) {
        this.lat = lat;
    }

    public String getLog() {
        return log;
    }

    public void setLog(String log) {
        this.log = log;
    }

    public String[] getSpeed() {
        return speed;
    }

    public void setSpeed(String[] speed) {
        this.speed = speed;
    }
}
