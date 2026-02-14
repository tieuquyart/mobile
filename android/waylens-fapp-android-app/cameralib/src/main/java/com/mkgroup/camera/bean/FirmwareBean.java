package com.mkgroup.camera.bean;

public class FirmwareBean {

    /**
     * id : 12
     * hardwareVersion : SC_V1H
     * firmware : 2.747.45.132.509
     * firmwareShort : 1.13.10
     * description : Update several functions.
     * md5sum : aebf837fbba91498ba8fdff3f2d8bdc2
     * file : https://tscastle.cam2cloud.com:9002/file/SC_V1H_2.747.45.132.509_1.13.10.tsf
     * size : 22603776
     * releaseTime : 1565858184973
     */

    private int id;
    private String hardwareVersion;
    private String firmware;
    private String firmwareShort;
    private Firmware.Description description;
    private String md5sum;
    private String file;
    private int size;
    private long releaseTime;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public Firmware.Description getDescription() {
        return description;
    }

    public void setDescription(Firmware.Description description) {
        this.description = description;
    }

    public String getMd5sum() {
        return md5sum;
    }

    public void setMd5sum(String md5sum) {
        this.md5sum = md5sum;
    }

    public String getFile() {
        return file;
    }

    public void setFile(String file) {
        this.file = file;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public long getReleaseTime() {
        return releaseTime;
    }

    public void setReleaseTime(long releaseTime) {
        this.releaseTime = releaseTime;
    }

    @Override
    public String toString() {
        return "FirmwareBean{" +
                "id=" + id +
                ", hardwareVersion='" + hardwareVersion + '\'' +
                ", firmware='" + firmware + '\'' +
                ", firmwareShort='" + firmwareShort + '\'' +
                ", description=" + description +
                ", md5sum='" + md5sum + '\'' +
                ", file='" + file + '\'' +
                ", size=" + size +
                ", releaseTime=" + releaseTime +
                '}';
    }
}
