package com.mkgroup.camera.message.bean;

import com.google.gson.annotations.SerializedName;

public class CoverBean {


    @SerializedName("mode")
    private String mode;


    // Getter

    public String getMode() { return mode; }

    // Setter

    public void setMode(String mode) { this.mode = mode; }
}
