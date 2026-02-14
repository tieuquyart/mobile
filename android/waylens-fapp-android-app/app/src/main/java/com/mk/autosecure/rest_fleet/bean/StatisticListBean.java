package com.mk.autosecure.rest_fleet.bean;

public class StatisticListBean {

    /**
     * date : 2019-07-02
     * mileage : 508
     * duration : 19911000
     * event : 5
     */

    private String date;
    private int mileage;
    private long duration;
    private int event;

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public int getMileage() {
        return mileage;
    }

    public void setMileage(int mileage) {
        this.mileage = mileage;
    }

    public long getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public int getEvent() {
        return event;
    }

    public void setEvent(int event) {
        this.event = event;
    }

    @Override
    public String toString() {
        return "StatisticListBean{" +
                "date='" + date + '\'' +
                ", mileage=" + mileage +
                ", duration=" + duration +
                ", event=" + event +
                '}';
    }
}
