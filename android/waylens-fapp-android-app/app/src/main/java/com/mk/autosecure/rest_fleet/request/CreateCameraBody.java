package com.mk.autosecure.rest_fleet.request;

public class CreateCameraBody {

    private String sn;
    private String cameraType;
    private String password;
    private String phone;
    private String installationDate;

    public CreateCameraBody(String sn, String cameraType, String password, String phone, String installationDate) {
        this.sn = sn;
        this.cameraType = cameraType;
        this.password = password;
        this.phone = phone;
        this.installationDate = installationDate;
    }

    public String getSn() {
        return sn;
    }

    public void setSn(String sn) {
        this.sn = sn;
    }

    public String getCameraType() {
        return cameraType;
    }

    public void setCameraType(String cameraType) {
        this.cameraType = cameraType;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getInstallationDate() {
        return installationDate;
    }

    public void setInstallationDate(String installationDate) {
        this.installationDate = installationDate;
    }
}
