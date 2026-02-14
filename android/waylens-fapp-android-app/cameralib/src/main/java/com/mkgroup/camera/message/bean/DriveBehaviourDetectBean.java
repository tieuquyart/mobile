package com.mkgroup.camera.message.bean;

import java.util.List;

public class DriveBehaviourDetectBean {

    /**
     * enabled : true
     * param : [280,-300,350,15,12,15,25,25,25,25,25,25,1,1,1]
     */

    private boolean enabled;
    private List<Integer> param;

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public List<Integer> getParam() {
        return param;
    }

    public void setParam(List<Integer> param) {
        this.param = param;
    }
}
