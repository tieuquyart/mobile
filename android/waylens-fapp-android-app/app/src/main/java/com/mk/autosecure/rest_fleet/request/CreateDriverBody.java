package com.mk.autosecure.rest_fleet.request;

public class CreateDriverBody {
    public String name;
    public String gender;
    public String phoneNo;
    public String idNumber;
    public String license;
    public String licenseType;
    public String drivingYears;
    public String employeeId;

    public CreateDriverBody(String name, String gender, String phoneNo, String idNumber, String license, String licenseType, String drivingYears, String employeeId) {
        this.name = name;
        this.gender = "";
        this.phoneNo = phoneNo;
        this.idNumber = idNumber;
        this.license = license;
        this.licenseType = licenseType;
        this.drivingYears = drivingYears;
        this.employeeId = employeeId;
    }
}
