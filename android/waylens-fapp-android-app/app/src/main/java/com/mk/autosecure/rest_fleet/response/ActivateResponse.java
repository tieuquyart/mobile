package com.mk.autosecure.rest_fleet.response;

public class ActivateResponse extends Response {

    /**
     * iccid : 898607B0101730353150
     * state : ACTIVATED
     */

    private String iccid;
    private String state;

    public String getIccid() {
        return iccid;
    }

    public void setIccid(String iccid) {
        this.iccid = iccid;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    @Override
    public String toString() {
        return "ActivateResponse{" +
                "iccid='" + iccid + '\'' +
                ", state='" + state + '\'' +
                '}';
    }
}
