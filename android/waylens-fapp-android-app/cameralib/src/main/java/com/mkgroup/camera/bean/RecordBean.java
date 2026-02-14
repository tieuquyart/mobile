package com.mkgroup.camera.bean;

import java.util.Arrays;

public class RecordBean{
    String dateTime;
    String latitude;
    String longitude;
    String[] speeds;

    public String getDateTime() {
        return dateTime;
    }

    public void setDateTime(String dateTime) {
        this.dateTime = dateTime;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String[] getSpeeds() {
        return speeds;
    }

    public void setSpeeds(String[] speeds) {
        this.speeds = speeds;
    }

    @Override
    public String toString() {
        return "Record{" +
                "dateTime='" + dateTime + '\'' +
                ", latitude='" + latitude + '\'' +
                ", longitude='" + longitude + '\'' +
                ", speeds=" + Arrays.toString(speeds) +
                '}';
    }
}
