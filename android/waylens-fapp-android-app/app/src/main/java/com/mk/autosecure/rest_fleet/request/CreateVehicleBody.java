package com.mk.autosecure.rest_fleet.request;

public class CreateVehicleBody {

    public String plateNo;

    public String brand;

    public String vehicleNo;

    public String capacity;

    public String type;

    public String businessLicense;

    public CreateVehicleBody(String plateNo, String brand, String vehicleNo, String capacity, String type, String businessLicense) {
        this.plateNo = plateNo;
        this.brand = brand;
        this.vehicleNo = vehicleNo;
        this.capacity = capacity;
        this.type = type;
        this.businessLicense = businessLicense;
    }
}
