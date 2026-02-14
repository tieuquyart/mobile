package com.mk.autosecure.rest_fleet.bean;

public class EventListBean {
    private String cameraSn;
    private double eventTotal;
    private String summaryTime;

    public EventListBean(String summaryTime) {
        this.summaryTime = summaryTime;
    }

    public EventListBean() {
    }

    public String getCameraSn() {
        return cameraSn;
    }

    public void setCameraSn(String cameraSn) {
        this.cameraSn = cameraSn;
    }

    public double getEventTotal() {
        return eventTotal;
    }

    public void setEventTotal(double eventTotal) {
        this.eventTotal = eventTotal;
    }

    public String getSummaryTime() {
        return summaryTime;
    }

    public void setSummaryTime(String summaryTime) {
        this.summaryTime = summaryTime;
    }
}
