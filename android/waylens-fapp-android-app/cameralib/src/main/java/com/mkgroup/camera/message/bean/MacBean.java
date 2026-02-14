package com.mkgroup.camera.message.bean;

import com.google.gson.annotations.SerializedName;

public class MacBean {

    @SerializedName("macWlan0")
    private String macWlan0;

    @SerializedName("licenseIvlpr")
    private String licenseIvlpr;

    @SerializedName("ivlprError")
    private String ivlprError;

    // Getter
    public String getMacWlan0() { return macWlan0; }
    public String getLicenseIvlpr() { return licenseIvlpr; }
    public String getIvlprError() { return ivlprError; }

    // Setter
    public void setMacWlan0(String macWlan0) { this.macWlan0 = macWlan0; }
    public void setLicenseIvlpr(String licenseIvlpr) { this.licenseIvlpr = licenseIvlpr; }
    public void setIvlprError(String ivlprError) { this.ivlprError = ivlprError; }
}
