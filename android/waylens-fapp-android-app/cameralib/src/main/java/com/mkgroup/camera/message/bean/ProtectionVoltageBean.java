package com.mkgroup.camera.message.bean;

public class ProtectionVoltageBean {

    /**
     * mv : 11900
     */

    private int mv;

    public ProtectionVoltageBean(int mv) {
        this.mv = mv;
    }

    public int getMv() {
        return mv;
    }

    public void setMv(int mv) {
        this.mv = mv;
    }
}
