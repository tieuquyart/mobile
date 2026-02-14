package com.mkgroup.camera.message.bean;

public class StateBean {
    /**
     * state : recording
     * recordLength : 11400
     * tfState : normal
     */

    private String state;
    private int recordLength;
    private String tfState;

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public int getRecordLength() {
        return recordLength;
    }

    public void setRecordLength(int recordLength) {
        this.recordLength = recordLength;
    }

    public String getTfState() {
        return tfState;
    }

    public void setTfState(String tfState) {
        this.tfState = tfState;
    }
}
