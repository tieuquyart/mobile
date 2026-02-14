package com.mkgroup.camera.message.bean;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;

public class TCVN02Bean implements Serializable {
    private String drv_name;
    private String license_id;
    private String start_time;
    private String start_GPS;
    private String finish_time;
    private String finish_GPS;

    public String getDrv_name() {
        return drv_name;
    }

    public void setDrv_name(String drv_name) {
        this.drv_name = drv_name;
    }

    public String getLicense_id() {
        return license_id;
    }

    public void setLicense_id(String license_id) {
        this.license_id = license_id;
    }

    public String getStart_time() {
        return start_time;
    }

    public void setStart_time(String start_time) {
        this.start_time = start_time;
    }

    public String getStart_GPS() {
        return start_GPS;
    }

    public void setStart_GPS(String start_GPS) {
        this.start_GPS = start_GPS;
    }

    public String getFinish_time() {
        return finish_time;
    }

    public void setFinish_time(String finish_time) {
        this.finish_time = finish_time;
    }

    public String getFinish_GPS() {
        return finish_GPS;
    }

    public void setFinish_GPS(String finish_GPS) {
        this.finish_GPS = finish_GPS;
    }
}
