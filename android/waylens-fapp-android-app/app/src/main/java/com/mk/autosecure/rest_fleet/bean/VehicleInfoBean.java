package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;

public class VehicleInfoBean implements Serializable {

    /**
     * brand: "Honda"
     * businessLicense: "MK Vision"
     * cameraId: 10
     * cameraSn: "6B2BN9MB"
     * capacity: "2600"
     * createTime: "2022-01-26T17:14:56"
     * driverId: 9
     * driverLicense: "323456"
     * driverName: "KhoiLT"
     * employeeId: "3"
     * id: 14
     * plateNo: "29A18262"
     * type: "SUV"
     * updateTime: "2022-01-26T17:15:31"
     * vehicleNo: "mk-333"
     */

    private String brand;
    private String businessLicense;
    private int cameraId;
    private String cameraSn;
    private String capacity;
    private String createTime;
    private int driverId;
    private String driverLicense;
    private String driverName;
    private String employeeId;
    private int id;
    private String plateNo;
    private String type;
    private String updateTime;
    private String vehicleNo;

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getBusinessLicense() {
        return businessLicense;
    }

    public void setBusinessLicense(String businessLicense) {
        this.businessLicense = businessLicense;
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

    public String getCapacity() {
        return capacity;
    }

    public void setCapacity(String capacity) {
        this.capacity = capacity;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public int getDriverId() {
        return driverId;
    }

    public void setDriverId(int driverId) {
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

    public String getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime;
    }

    public String getVehicleNo() {
        return vehicleNo;
    }

    public void setVehicleNo(String vehicleNo) {
        this.vehicleNo = vehicleNo;
    }

    @Override
    public String toString() {
        return "VehicleInfoBean{" +
                "brand='" + brand + '\'' +
                "businessLicense='"+ businessLicense + '\''+
                ", cameraId=" + cameraId +
                ", cameraSn='" + cameraSn + '\'' +
                ", capacity='" + capacity + '\'' +
                ", createTime='" + createTime + '\'' +
                ", driverId=" + driverId +
                ", driverLicense='" + driverLicense + '\'' +
                ", driverName='" + driverName + '\'' +
                ", employeeId='" + employeeId + '\'' +
                ", id=" + id +
                ", plateNo='" + plateNo + '\'' +
                ", type='" + type + '\'' +
                ", updateTime='" + updateTime + '\'' +
                ", vehicleNo='" + vehicleNo + '\'' +
                '}';
    }
}
