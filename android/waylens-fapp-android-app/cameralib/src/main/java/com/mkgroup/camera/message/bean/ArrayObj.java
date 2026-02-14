package com.mkgroup.camera.message.bean;

import com.google.gson.annotations.SerializedName;

public class ArrayObj {

    @SerializedName("name")
    private String name;

    @SerializedName("id")
    private Number id;

    @SerializedName("licenseCode")
    private String licenseCode;

    // Getter
    public String getMacWlan0() { return name; }
    public Number getLicenseIvlpr() { return id; }
    public String getIvlprError() { return licenseCode; }

    // Setter
    public void setMacWlan0(String name) { this.name = name; }
    public void setLicenseIvlpr(Number id) { this.id = id; }
    public void setIvlprError(String licenseCode) { this.licenseCode = licenseCode; }
}


