package com.mk.autosecure.rest_fleet.bean;

import com.mk.autosecure.HornApplication;
import com.mk.autosecure.R;
import com.mk.autosecure.libs.utils.StringUtils;

import java.io.Serializable;

public class DriverInfoBean implements Serializable {

    /**
     birthDate: null
     createTime: "2022-01-17T14:25:35"
     drivingYears: 6
     employeeId: "7"
     gender: 0
     id: 10
     idNumber: "113236"
     license: "132456"
     licenseType: "3"
     name: "TungNS1"
     phoneNo: "0855140137"
     updateTime: "2022-02-07T16:18:30"
     */

    private String birthDate;
    private String createTime;
    private String drivingYears;
    private String employeeId;
    private int gender;
    private int id;
    private String idNumber;
    private String license;
    private String licenseType;
    private String name;
    private String phoneNo;
    private String updateTime;

    public String getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(String birthDate) {
        this.birthDate = birthDate;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public String getDrivingYears() {
        return drivingYears;
    }

    public void setDrivingYears(String drivingYears) {
        this.drivingYears = drivingYears;
    }

    public String getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
    }

    public int getGender() {
        return gender;
    }

    public void setGender(int gender) {
        this.gender = gender;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getIdNumber() {
        return idNumber;
    }

    public void setIdNumber(String idNumber) {
        this.idNumber = idNumber;
    }

    public String getLicense() {
        return license;
    }

    public void setLicense(String license) {
        this.license = license;
    }

    public String getLicenseType() {
        return licenseType;
    }

    public void setLicenseType(String licenseType) {
        this.licenseType = licenseType;
    }

    public String getName() {
        return !StringUtils.isEmpty(name) ? name : "Không có tên";
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhoneNo() {
        return phoneNo;
    }

    public void setPhoneNo(String phoneNo) {
        this.phoneNo = phoneNo;
    }

    public String getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime;
    }

    @Override
    public String toString() {
        return "DriverInfoBean{" +
                "birthDate='" + birthDate + '\'' +
                ", createTime='" + createTime + '\'' +
                ", drivingYears=" + drivingYears +
                ", employeeId='" + employeeId + '\'' +
                ", gender=" + gender +
                ", id=" + id +
                ", idNumber='" + idNumber + '\'' +
                ", license='" + license + '\'' +
                ", licenseType='" + licenseType + '\'' +
                ", name='" + name + '\'' +
                ", phoneNo='" + phoneNo + '\'' +
                ", updateTime='" + updateTime + '\'' +
                '}';
    }
}
