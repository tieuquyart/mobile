package com.mk.autosecure.rest_fleet.bean;

public class HoursListBean {
    private String cameraSn;
    private double distanceTotal;
    private int driverId;
    private String driverName;
    private double eventTotal;
    private double hoursTotal;
    private String plateNo;
    private String summaryTime;

    public HoursListBean() {
    }

    public HoursListBean(String cameraSn, double distanceTotal, int driverId, String driverName, double eventTotal, double hoursTotal, String plateNo, String summaryTime) {
        this.cameraSn = cameraSn;
        this.distanceTotal = distanceTotal;
        this.driverId = driverId;
        this.driverName = driverName;
        this.eventTotal = eventTotal;
        this.hoursTotal = hoursTotal;
        this.plateNo = plateNo;
        this.summaryTime = summaryTime;
    }

    public HoursListBean(String summaryTime) {
        this.summaryTime = summaryTime;
    }

    public String getCameraSn() {
        return cameraSn;
    }

    public void setCameraSn(String cameraSn) {
        this.cameraSn = cameraSn;
    }

    public double getDistanceTotal() {
        return distanceTotal;
    }

    public void setDistanceTotal(double distanceTotal) {
        this.distanceTotal = distanceTotal;
    }

    public int getDriverId() {
        return driverId;
    }

    public void setDriverId(int driverId) {
        this.driverId = driverId;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public double getEventTotal() {
        return eventTotal;
    }

    public void setEventTotal(double eventTotal) {
        this.eventTotal = eventTotal;
    }

    public double getHoursTotal() {
        return hoursTotal;
    }

    public void setHoursTotal(double hoursTotal) {
        this.hoursTotal = hoursTotal;
    }

    public String getPlateNo() {
        return plateNo;
    }

    public void setPlateNo(String plateNo) {
        this.plateNo = plateNo;
    }

    public String getSummaryTime() {
        return summaryTime;
    }

    public void setSummaryTime(String summaryTime) {
        this.summaryTime = summaryTime;
    }
}
