package com.mkgroup.camera.message.bean;

public class EnabledBean {

    /**
     * enabled : true
     */

    private boolean enabled;

    public EnabledBean(boolean enabled) {
        this.enabled = enabled;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }
}
