package com.mkgroup.camera.bean;

import java.io.Serializable;

public class FleetCameraBean implements Serializable {
    public static final String ACTIVATED = "ACTIVATED";

    /*createTime: "2022-02-07T16:18:06"
    employeeId: "7"
    fccid: "2AKAF-TW06C2"
    firmware: null
    firmwareShort: null
    groupId: null
    hardwareModel: null
    hardwareVersion: null
    iccid: null
    id: 18
    outerId: null
    password: "46451713"
    phone: "0855140137"
    plateNo: ""
    poweredBy: null
    rotate: null
    simState: null
    sn: "6B2BN9PB"
    ssid: "MK-BN9PB"
    status: 0
    updateTime*/

    private String cameraType;
    private String createTime;
    private String employeeId;
    private String fccid;
    private String firmware;
    private String firmwareShort;
    private String groupId;
    private String hardwareModel;
    private String hardwareVersion;
    private String iccid;
    private int id;
    private String installationDate;
    private int outerId;
    private String password;
    private String phone;
    private String plateNo;
    private String poweredBy;
    private String rotate;
    private String simState;
    private String sn;
    private String ssid;
    private int status;
    private String updateTime;

    public String getCameraType() {
        return cameraType;
    }

    public void setCameraType(String cameraType) {
        this.cameraType = cameraType;
    }

    public String getCreateTime() {
        return createTime;
    }

    public void setCreateTime(String createTime) {
        this.createTime = createTime;
    }

    public String getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
    }

    public String getFccid() {
        return fccid;
    }

    public void setFccid(String fccid) {
        this.fccid = fccid;
    }

    public String getFirmware() {
        return firmware;
    }

    public void setFirmware(String firmware) {
        this.firmware = firmware;
    }

    public String getFirmwareShort() {
        return firmwareShort;
    }

    public void setFirmwareShort(String firmwareShort) {
        this.firmwareShort = firmwareShort;
    }

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public String getHardwareModel() {
        return hardwareModel;
    }

    public void setHardwareModel(String hardwareModel) {
        this.hardwareModel = hardwareModel;
    }

    public String getHardwareVersion() {
        return hardwareVersion;
    }

    public void setHardwareVersion(String hardwareVersion) {
        this.hardwareVersion = hardwareVersion;
    }

    public String getIccid() {
        return iccid;
    }

    public void setIccid(String iccid) {
        this.iccid = iccid;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getInstallationDate() {
        return installationDate;
    }

    public void setInstallationDate(String installationDate) {
        this.installationDate = installationDate;
    }

    public int getOuterId() {
        return outerId;
    }

    public void setOuterId(int outerId) {
        this.outerId = outerId;
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

    public String getPlateNo() {
        return plateNo;
    }

    public void setPlateNo(String plateNo) {
        this.plateNo = plateNo;
    }

    public String getPoweredBy() {
        return poweredBy;
    }

    public void setPoweredBy(String poweredBy) {
        this.poweredBy = poweredBy;
    }

    public String getRotate() {
        return rotate;
    }

    public void setRotate(String rotate) {
        this.rotate = rotate;
    }

    public String getSimState() {
        return simState;
    }

    public void setSimState(String simState) {
        this.simState = simState;
    }

    public String getSn() {
        return sn;
    }

    public void setSn(String sn) {
        this.sn = sn;
    }

    public String getSsid() {
        return ssid;
    }

    public void setSsid(String ssid) {
        this.ssid = ssid;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime;
    }

    @Override
    public String toString() {
        return "CameraBean{" +
                "createTime='" + createTime + '\'' +
                ", fccid='" + fccid + '\'' +
                ", firmware='" + firmware + '\'' +
                ", firmwareShort='" + firmwareShort + '\'' +
                ", groupId='" + groupId + '\'' +
                ", hardwareModel='" + hardwareModel + '\'' +
                ", hardwareVersion='" + hardwareVersion + '\'' +
                ", iccid='" + iccid + '\'' +
                ", id=" + id +
                ", outerId=" + outerId +
                ", password='" + password + '\'' +
                ", phone='" + phone + '\'' +
                ", poweredBy='" + poweredBy + '\'' +
                ", rotate='" + rotate + '\'' +
                ", simState='" + simState + '\'' +
                ", sn='" + sn + '\'' +
                ", ssid='" + ssid + '\'' +
                ", status=" + status +
                ", updateTime='" + updateTime + '\'' +
                '}';
    }
}
