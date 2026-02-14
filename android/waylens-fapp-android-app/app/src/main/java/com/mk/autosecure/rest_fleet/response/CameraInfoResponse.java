package com.mk.autosecure.rest_fleet.response;

public class CameraInfoResponse {

    /**
     * id : 134
     * serialNumber : 2B17NKZ2
     * iccid : 89860402101872171468
     * hardwareModel : 2B
     * hardwareVersion : SC_V0D
     * firmware :
     * firmwareShort :
     * mode : parking
     * simState : DEACTIVATED
     * dataUsageInKB : 0
     */

    private int id;
    private String serialNumber;
    private String iccid;
    private String hardwareModel;
    private String hardwareVersion;
    private String firmware;
    private String firmwareShort;
    private String mode;
    private String simState;
    private int dataUsageInKB;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public String getIccid() {
        return iccid;
    }

    public void setIccid(String iccid) {
        this.iccid = iccid;
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

    public String getMode() {
        return mode;
    }

    public void setMode(String mode) {
        this.mode = mode;
    }

    public String getSimState() {
        return simState;
    }

    public void setSimState(String simState) {
        this.simState = simState;
    }

    public int getDataUsageInKB() {
        return dataUsageInKB;
    }

    public void setDataUsageInKB(int dataUsageInKB) {
        this.dataUsageInKB = dataUsageInKB;
    }
}
