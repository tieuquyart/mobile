package com.mkgroup.camera.message.bean;

public class DeviceInfoBean {

    /**
     * make : TranSee
     * model : SC_V0D
     * api : 1.15.03
     * date : UTC 2020/02/21 09:33:50
     * build : 2.757.49.175.620
     * software :
     * sn : 2B17NKK5
     */

    private String make;
    private String model;
    private String api;
    private String date;
    private String build;
    private String software;
    private String sn;

    public String getMake() {
        return make;
    }

    public void setMake(String make) {
        this.make = make;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getApi() {
        return api;
    }

    public void setApi(String api) {
        this.api = api;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getBuild() {
        return build;
    }

    public void setBuild(String build) {
        this.build = build;
    }

    public String getSoftware() {
        return software;
    }

    public void setSoftware(String software) {
        this.software = software;
    }

    public String getSn() {
        return sn;
    }

    public void setSn(String sn) {
        this.sn = sn;
    }

    @Override
    public String toString() {
        return "DeviceInfoBean{" +
                "make='" + make + '\'' +
                ", model='" + model + '\'' +
                ", api='" + api + '\'' +
                ", date='" + date + '\'' +
                ", build='" + build + '\'' +
                ", software='" + software + '\'' +
                ", sn='" + sn + '\'' +
                '}';
    }
}
