package com.mkgroup.camera.message.bean;

import com.google.gson.annotations.SerializedName;

public class SradarBean {


    @SerializedName("statusConnect")
    private String statusConnect;

    @SerializedName("detectionType")
    private String detectionType;

    // Getter

    public String getstatusConnect() { return statusConnect; }
    public String getDetectionType() { return detectionType; }

    // Setter

    public void setStatusConnect() { this.statusConnect = statusConnect; }
    public void setDetectionType(String detectionType) { this.detectionType = detectionType; }
}
