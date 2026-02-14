package com.mkgroup.camera.message.bean;

public class MountVersionBean {

    /**
     * hw_version : WC
     * sv_version : 3A
     * vercode : 370
     * support_4g : true
     * imei : 866626030187137
     */

    private String hw_version;
    private String sv_version;
    private String vercode;
    private boolean support_4g;
    private String imei;

    public String getHw_version() {
        return hw_version;
    }

    public void setHw_version(String hw_version) {
        this.hw_version = hw_version;
    }

    public String getSv_version() {
        return sv_version;
    }

    public void setSv_version(String sv_version) {
        this.sv_version = sv_version;
    }

    public String getVercode() {
        return vercode;
    }

    public void setVercode(String vercode) {
        this.vercode = vercode;
    }

    public boolean isSupport_4g() {
        return support_4g;
    }

    public void setSupport_4g(boolean support_4g) {
        this.support_4g = support_4g;
    }

    public String getImei() {
        return imei;
    }

    public void setImei(String imei) {
        this.imei = imei;
    }
}
