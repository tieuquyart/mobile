package com.mkgroup.camera.message.bean;

public class EnableBean {

    /**
     * enable : true
     */

    private boolean enable;

    public EnableBean(boolean enable) {
        this.enable = enable;
    }

    public boolean isEnable() {
        return enable;
    }

    public void setEnable(boolean enable) {
        this.enable = enable;
    }
}
