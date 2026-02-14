package com.mkgroup.camera.message.bean;

public class TrustACCStatusBean {

    /**
     * trust : true
     */

    private boolean trust;

    public TrustACCStatusBean(boolean trust) {
        this.trust = trust;
    }

    public boolean isTrust() {
        return trust;
    }

    public void setTrust(boolean trust) {
        this.trust = trust;
    }
}
