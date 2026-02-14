package com.mk.autosecure.rest_fleet.request;

public class EditVehicleBody {
    private String brand;
    private String capacity;
    private int id;
    private String plateNo;
    private String type;
    private String vehicleNo;
    private String businessLicense;

    public EditVehicleBody( String plateNo, String brand,  String vehicleNo, String capacity, String type, int id, String businessLicense) {
        this.brand = brand;
        this.capacity = capacity;
        this.id = id;
        this.plateNo = plateNo;
        this.type = type;
        this.vehicleNo = vehicleNo;
        this.businessLicense = businessLicense;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getCapacity() {
        return capacity;
    }

    public void setCapacity(String capacity) {
        this.capacity = capacity;
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

    public String getVehicleNo() {
        return vehicleNo;
    }

    public void setVehicleNo(String vehicleNo) {
        this.vehicleNo = vehicleNo;
    }

    public String getBusinessLicense() {
        return businessLicense;
    }

    public void setBusinessLicense(String businessLicense) {
        this.businessLicense = businessLicense;
    }
}
