package com.mkgroup.camera.message.bean;

public class LTEInformationBean {

    /**
     * version : ME3630U1AV1.0B05
     * version_internal : QS_ME3630U1AV1.0B04 [Apr 18 2019 13:43:33]
     * iccid : 89860318740211144091
     * apn : waylens.iot.com.attz
     */

    private String version;
    private String version_internal;
    private String iccid;
    private String apn;

    public LTEInformationBean(String apn) {
        this.apn = apn;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getVersion_internal() {
        return version_internal;
    }

    public void setVersion_internal(String version_internal) {
        this.version_internal = version_internal;
    }

    public String getIccid() {
        return iccid;
    }

    public void setIccid(String iccid) {
        this.iccid = iccid;
    }

    public String getApn() {
        return apn;
    }

    public void setApn(String apn) {
        this.apn = apn;
    }
}
