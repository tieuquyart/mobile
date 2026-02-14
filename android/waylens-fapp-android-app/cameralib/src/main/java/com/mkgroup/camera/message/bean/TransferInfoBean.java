package com.mkgroup.camera.message.bean;

public class TransferInfoBean {

    private String state;
    private int size;
    private int progress;
    private int errorCode;

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }

    public int getProgress() {
        return progress;
    }

    public void setProgress(int progress) {
        this.progress = progress;
    }

    public int getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(int errorCode) {
        this.errorCode = errorCode;
    }

    @Override
    public String toString() {
        return "TransferInfoBean{" +
                "state='" + state + '\'' +
                ", size=" + size +
                ", progress=" + progress +
                ", errorCode=" + errorCode +
                '}';
    }
}
