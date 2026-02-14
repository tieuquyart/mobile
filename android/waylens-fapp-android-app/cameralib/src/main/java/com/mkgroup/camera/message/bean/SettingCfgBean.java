package com.mkgroup.camera.message.bean;

import java.io.Serializable;

public class SettingCfgBean implements Serializable {
    String latest_modify;

    public SettingCfgBean(String lasted_modify) {
        this.latest_modify = lasted_modify;
    }

    public String getLasted_modify() {
        return latest_modify;
    }

    public void setLasted_modify(String lasted_modify) {
        this.latest_modify = lasted_modify;
    }
}
