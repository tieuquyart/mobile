package com.mkgroup.camera.message.bean;

public class TransferFirmwareBean {
    private int size;
    private String md5;
    private boolean reboot;

    public TransferFirmwareBean(int size, String md5, boolean reboot) {
        this.size = size;
        this.md5 = md5;
        this.reboot = reboot;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public String getMd5() {
        return md5;
    }

    public void setMd5(String md5) {
        this.md5 = md5;
    }

    public boolean isReboot() {
        return reboot;
    }

    public void setReboot(boolean reboot) {
        this.reboot = reboot;
    }
}
