package com.mk.autosecure.rest_fleet.request;

public class DrivingTimeBody {
    private String end_time;
    private String start_time;
    private boolean continuous;

    public DrivingTimeBody(String end_time, String start_time, boolean continuous) {
        this.end_time = end_time;
        this.start_time = start_time;
        this.continuous = continuous;
    }

    public String getEnd_time() {
        return end_time;
    }

    public void setEnd_time(String end_time) {
        this.end_time = end_time;
    }

    public String getStart_time() {
        return start_time;
    }

    public void setStart_time(String start_time) {
        this.start_time = start_time;
    }

    public boolean getContinuous() {
        return continuous;
    }

    public void setContinuous(boolean continuous) {
        this.continuous = continuous;
    }

    @Override
    public String toString() {
        return "DrivingTimeBody{" +
                "end_time='" + end_time + '\'' +
                ", start_time='" + start_time + '\'' +
                ", continuous='" + continuous + '\'' +
                '}';
    }
}
