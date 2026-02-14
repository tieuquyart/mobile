package com.mk.autosecure.rest_fleet.bean;

public class StatisticBean {

    /**
     * from : 1571551200000
     * to : 1571637600000
     * mileage : 3202
     * duration : 16994
     * event : 2
     */

    private long from;
    private long to;
    private int mileage;
    private int duration;
    private int event;

    public long getFrom() {
        return from;
    }

    public void setFrom(long from) {
        this.from = from;
    }

    public long getTo() {
        return to;
    }

    public void setTo(long to) {
        this.to = to;
    }

    public int getMileage() {
        return mileage;
    }

    public void setMileage(int mileage) {
        this.mileage = mileage;
    }

    public int getDuration() {
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
        return "StatisticBean{" +
                "from=" + from +
                ", to=" + to +
                ", mileage=" + mileage +
                ", duration=" + duration +
                ", event=" + event +
                '}';
    }
}
