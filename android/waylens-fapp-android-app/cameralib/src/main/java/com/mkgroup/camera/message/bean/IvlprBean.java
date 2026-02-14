package com.mkgroup.camera.message.bean;

import com.google.gson.annotations.SerializedName;

public class IvlprBean {

    @SerializedName("val")
    private String val;

    // Getter
    public String getValIvlpr() { return val; }

    // Setter
    public void setValIvlpr(String val) { this.val = val; }
}
