package com.mk.autosecure.rest_fleet.bean;

public class CameraEventBean {

    /**
     * cameraSn: "6B2BN9MB"
     * clipId: "631421951591718912"
     * createTime: "2021-12-17T08:00:03"
     * driverId: 5
     * driverLicense: "Automobile"
     * driverName: "HN"
     * duration: 6000
     * eventCategory: "DMS"
     * eventLevel: "DEFAULT"
     * eventType: "NO_DRIVER"
     * gpsAltitude: -2.1
     * gpsHdop: 100
     * gpsHeading: 4.699999809265137
     * gpsLatitude: 21.009438
     * gpsLongitude: 105.720568
     * gpsSpeed: 0
     * gpsTime: "2021-12-16T18:32:07"
     * gpsVdop: 90
     * id: 112
     * plateNo: "30B-3333"
     * startTime: "2021-12-16T18:32:09"
     * tripId: "13b41d04-d833-42e4-b009-fbb7e83a48c0"
     * updateTime: "2021-12-17T08:00:03"
     * vehicleId: 8
     * */

    private String cameraSn;
    private String clipID;
    private String createTime;
    private String driverId;
    private String driverLicense;
    private String driverName;
    private long duration;
    private String eventCategory;
    private String eventLevel;
    private String eventType;
    private double gpsAltitude;
    private int gpsHdop;
    private double gpsHeading;
    private double gpsLatitude;
    private double gpsLongitude;
    private double gpsSpeed;
    private String gpsTime;
    private int gpsVdop;
    private int id;
    private String plateNo;
    private String startTime;
    private String tripId;
    private String updateTime;
    private int vehicleId;

    public String getCameraSn() {
        return cameraSn;
    }

    public void setCameraSn(String cameraSn) {
        this.cameraSn = cameraSn;
    }

    public String getClipID() {
        return clipID;
    }

    public void setClipID(String clipID) {
        this.clipID = clipID;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public String getDriverId() {
        return driverId;
    }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }

    public String getDriverLicense() {
        return driverLicense;
    }

    public void setDriverLicense(String driverLicense) {
        this.driverLicense = driverLicense;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public long getDuration() {
        return duration;
    }

    public void setDuration(long duration) {
        this.duration = duration;
    }

    public String getEventCategory() {
        return eventCategory;
    }

    public void setEventCategory(String eventCategory) {
        this.eventCategory = eventCategory;
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

    public double getGpsAltitude() {
        return gpsAltitude;
    }

    public void setGpsAltitude(double gpsAltitude) {
        this.gpsAltitude = gpsAltitude;
    }

    public int getGpsHdop() {
        return gpsHdop;
    }

    public void setGpsHdop(int gpsHdop) {
        this.gpsHdop = gpsHdop;
    }

    public double getGpsHeading() {
        return gpsHeading;
    }

    public void setGpsHeading(double gpsHeading) {
        this.gpsHeading = gpsHeading;
    }

    public double getGpsLatitude() {
        return gpsLatitude;
    }

    public void setGpsLatitude(double gpsLatitude) {
        this.gpsLatitude = gpsLatitude;
    }

    public double getGpsLongitude() {
        return gpsLongitude;
    }

    public void setGpsLongitude(double gpsLongitude) {
        this.gpsLongitude = gpsLongitude;
    }

    public double getGpsSpeed() {
        return gpsSpeed;
    }

    public void setGpsSpeed(double gpsSpeed) {
        this.gpsSpeed = gpsSpeed;
    }

    public String getGpsTime() {
        return gpsTime;
    }

    public void setGpsTime(String gpsTime) {
        this.gpsTime = gpsTime;
    }

    public int getGpsVdop() {
        return gpsVdop;
    }

    public void setGpsVdop(int gpsVdop) {
        this.gpsVdop = gpsVdop;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getPlateNo() {
        return plateNo;
    }

    public void setPlateNo(String plateNo) {
        this.plateNo = plateNo;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getTripId() {
        return tripId;
    }

    public void setTripId(String tripId) {
        this.tripId = tripId;
    }

    public String getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    @Override
    public String toString() {
        return "CameraEventBean{" +
                "plateNumber='" + plateNo + '\'' +
                ", driver='" + driverId + '\'' +
                ", startTime=" + startTime +
                ", cameraSn='" + cameraSn+ '\'' +
                ", clipID='" + clipID + '\'' +
                ", eventType='" + eventType + '\'' +
                ", duration=" + duration +
                ", speed=" + gpsSpeed +
                ", heading=" + gpsHeading +
                ", hDop=" + gpsHdop +
                ", vDop=" + gpsVdop +
                '}';
    }
}
