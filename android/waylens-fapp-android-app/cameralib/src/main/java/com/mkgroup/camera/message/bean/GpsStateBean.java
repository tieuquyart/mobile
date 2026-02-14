package com.mkgroup.camera.message.bean;

public class GpsStateBean {

    /**
     * state : on
     * num_svs : 0
     */

    private String state;
    private int num_svs;

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public int getNum_svs() {
        return num_svs;
    }

    public void setNum_svs(int num_svs) {
        this.num_svs = num_svs;
    }
}
