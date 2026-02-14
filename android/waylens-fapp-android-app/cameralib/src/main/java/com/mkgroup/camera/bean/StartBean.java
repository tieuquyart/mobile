package com.mkgroup.camera.bean;

public class StartBean {
    String status;
    String dateTime;
    String latitude;
    String longitude;
    String driverName;
    String plateNo;
    String licenseNo;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDateTime() {
        return dateTime;
    }

    public void setDateTime(String dateTime) {
        this.dateTime = dateTime;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }

    public String getPlateNo() {
        return plateNo;
    }

    public void setPlateNo(String plateNo) {
        this.plateNo = plateNo;
    }

    public String getLicenseNo() {
        return licenseNo;
    }

    public void setLicenseNo(String licenseNo) {
        this.licenseNo = licenseNo;
    }

    @Override
    public String toString() {
        return "StartBean{" +
                "status='" + status + '\'' +
                ", dateTime='" + dateTime + '\'' +
                ", latitude='" + latitude + '\'' +
                ", longitude='" + longitude + '\'' +
                ", driverName='" + driverName + '\'' +
                ", plateNo='" + plateNo + '\'' +
                ", licenseNo='" + licenseNo + '\'' +
                '}';
    }
}
