package com.mkgroup.camera.message.bean;

public class WifiInfoBean {

    /**
     * mode : P2P
     * ssid : Waylens-7NKK5
     * password : 81525413
     * band : 5G
     */

    private String mode;
    private String ssid;
    private String password;
    private String band;

    public String getMode() {
        return mode;
    }

    public void setMode(String mode) {
        this.mode = mode;
    }

    public String getSsid() {
        return ssid;
    }

    public void setSsid(String ssid) {
        this.ssid = ssid;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getBand() {
        return band;
    }

    public void setBand(String band) {
        this.band = band;
    }
}
