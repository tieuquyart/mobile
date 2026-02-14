package com.mk.autosecure.rest_fleet.bean;

import java.util.List;

public class TripBean implements Comparable<TripBean> {

    /**
     * "cameraId": 0,
     *       "cameraSn": "string",
     *       "createTime": "2021-12-21T02:36:03.232Z",
     *       "distance": 0,
     *       "driverId": 0,
     *       "driverName": "string",
     *       "drivingTime": "2021-12-21T02:36:03.232Z",
     *       "eventCount": 0,
     *       "gpsDataList": [
     *         {
     *           "coordinate": [
     *             0
     *           ],
     *           "eventCategory": "string",
     *           "eventId": 0,
     *           "eventLevel": "string",
     *           "eventType": "string",
     *           "hdop": 0,
     *           "heading": 0,
     *           "speed": 0,
     *           "time": "2021-12-21T02:36:03.232Z",
     *           "vdop": 0
     *         }
     *       ],
     *       "hours": 0,
     *       "id": 0,
     *       "parkingTime": "2021-12-21T02:36:03.232Z",
     *       "tripId": "string",
     *       "updateTime": "2021-12-21T02:36:03.232Z",
     *       "vehicleId": 0,
     *       "vehiclePlate": "string"
     */

    private int cameraId;
    private String cameraSn;
    private String createTime;
    private int distance;
    private int driverId;
    private String driverName;
    private String drivingTime;
    private int eventCount;
    private List<TrackBean>gpsDataList;
    private double hours;
    private int id;
    private String parkingTime;
    private String tripId;
    private String updateTime;
    private int vehicleId;
    private String vehicelPlate;

    private boolean isExpanded;

    public boolean isExpanded() {
        return isExpanded;
    }

    public void setExpanded(boolean expanded) {
        isExpanded = expanded;
    }

    public int getCameraId() {
        return cameraId;
    }

    public void setCameraId(int cameraId) {
        this.cameraId = cameraId;
    }

    public String getCameraSn() {
        return cameraSn;
    }

    public void setCameraSn(String cameraSn) {
        this.cameraSn = cameraSn;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public int getDistance() {
        return distance;
    }

    public void setDistance(int distance) {
        this.distance = distance;
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

    public String getDrivingTime() {
        return drivingTime;
    }

    public void setDrivingTime(String drivingTime) {
        this.drivingTime = drivingTime;
    }

    public int getEventCount() {
        return eventCount;
    }

    public void setEventCount(int eventCount) {
        this.eventCount = eventCount;
    }

    public List<TrackBean> getGpsDataList() {
        return gpsDataList;
    }

    public void setGpsDataList(List<TrackBean> gpsDataList) {
        this.gpsDataList = gpsDataList;
    }

    public double getHours() {
        return hours;
    }

    public void setHours(double hours) {
        this.hours = hours;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getParkingTime() {
        return parkingTime;
    }

    public void setParkingTime(String parkingTime) {
        this.parkingTime = parkingTime;
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

    public String getVehicelPlate() {
        return vehicelPlate;
    }

    public void setVehicelPlate(String vehicelPlate) {
        this.vehicelPlate = vehicelPlate;
    }

    @Override
    public String toString() {
        return "TripBean{" +
                "cameraId=" + cameraId +
                ", cameraSn='" + cameraSn + '\'' +
                ", createTime='" + createTime + '\'' +
                ", distance=" + distance +
                ", driverId=" + driverId +
                ", driverName='" + driverName + '\'' +
                ", drivingTime='" + drivingTime + '\'' +
                ", eventCount=" + eventCount +
                ", gpsDataList=" + gpsDataList +
                ", hours=" + hours +
                ", id=" + id +
                ", parkingTime='" + parkingTime + '\'' +
                ", tripId='" + tripId + '\'' +
                ", updateTime='" + updateTime + '\'' +
                ", vehicleId=" + vehicleId +
                ", vehicelPlate='" + vehicelPlate + '\'' +
                '}';
    }

    @Override
    public int compareTo(TripBean o) {
        if (getDrivingTime() == null || o.getDrivingTime() == null)
            return 0;
        return getDrivingTime().compareTo(o.getDrivingTime());
    }
}
