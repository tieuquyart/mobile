package com.mk.autosecure.rest_fleet.bean;

import java.util.List;

public class TrackBean {

    /**
     * "coordinate": [
     0
     ],
     "eventCategory": "string",
     "eventId": 0,
     "eventLevel": "string",
     "eventType": "string",
     "hdop": 0,
     "heading": 0,
     "speed": 0,
     "time": "2021-12-21T02:36:03.232Z",
     "vdop": 0
     */

    private List<Double> coordinate;
    private String eventCategory;
    private int eventId;
    private String eventLevel;
    private String eventType;
    private int hdop;
    private double heading;
    private double speed;
    private String time;
    private int vdop;

    public List<Double> getCoordinate() {
        return coordinate;
    }

    public void setCoordinate(List<Double> coordinate) {
        this.coordinate = coordinate;
    }

    public String getEventCategory() {
        return eventCategory;
    }

    public void setEventCategory(String eventCategory) {
        this.eventCategory = eventCategory;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public String getEventLevel() {
        return eventLevel;
    }

    public void setEventLevel(String eventLevel) {
        this.eventLevel = eventLevel;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public int getHdop() {
        return hdop;
    }

    public void setHdop(int hdop) {
        this.hdop = hdop;
    }

    public double getHeading() {
        return heading;
    }

    public void setHeading(double heading) {
        this.heading = heading;
    }

    public double getSpeed() {
        return speed;
    }

    public void setSpeed(double speed) {
        this.speed = speed;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public int getVdop() {
        return vdop;
    }

    public void setVdop(int vdop) {
        this.vdop = vdop;
    }

    @Override
    public String toString() {
        return "TrackBean{" +
                "coordinate=" + coordinate +
                ", eventCategory='" + eventCategory + '\'' +
                ", eventId=" + eventId +
                ", eventLevel='" + eventLevel + '\'' +
                ", eventType='" + eventType + '\'' +
                ", hdop=" + hdop +
                ", heading=" + heading +
                ", speed=" + speed +
                ", time='" + time + '\'' +
                ", vdop=" + vdop +
                '}';
    }
}
