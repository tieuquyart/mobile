package com.mk.autosecure.rest_fleet.request;

public class EditDriverBody {
    private int id;
    private String name;
    private String gender;
    private String phoneNo;
    private String idNumber;
    private String license;
    private String licenseType;
    private String drivingYears;
    private String employeeId;

    public EditDriverBody(int id, String name, String gender, String phoneNo, String idNumber, String license, String licenseType, String drivingYears, String employeeId) {
        this.id = id;
        this.name = name;
        this.gender = gender;
        this.phoneNo = phoneNo;
        this.idNumber = idNumber;
        this.license = license;
        this.licenseType = licenseType;
        this.drivingYears = drivingYears;
        this.employeeId = employeeId;
    }
}
