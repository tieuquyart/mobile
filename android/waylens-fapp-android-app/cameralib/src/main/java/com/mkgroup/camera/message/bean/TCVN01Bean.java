package com.mkgroup.camera.message.bean;

import java.io.Serializable;

public class TCVN01Bean implements Serializable {
    private String sup;
    private String type;
    private String sn;
    private String plate_num;
    private String spd_method;
    private String pulse_cfg;
    private String spd_limit;
    private String last_modified;
    private String last_updated;
    private String sig_stt;
    private String GPS_stt;
    private String mem_stt;
    private String total_mem;
    private String cur_driver;
    private String cont_drv_time;
    private String GPS_info;
    private String speed;
    private String time;
    private String stop_time_cfg;

    public String getSup() {
        return sup;
    }

    public void setSup(String sup) {
        this.sup = sup;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getSn() {
        return sn;
    }

    public void setSn(String sn) {
        this.sn = sn;
    }

    public String getPlate_num() {
        return plate_num;
    }

    public void setPlate_num(String plate_num) {
        this.plate_num = plate_num;
    }

    public String getSpd_method() {
        return spd_method;
    }

    public void setSpd_method(String spd_method) {
        this.spd_method = spd_method;
    }

    public String getPulse_cfg() {
        return pulse_cfg;
    }

    public void setPulse_cfg(String pulse_cfg) {
        this.pulse_cfg = pulse_cfg;
    }

    public String getSpd_limit() {
        return spd_limit;
    }

    public void setSpd_limit(String spd_limit) {
        this.spd_limit = spd_limit;
    }

    public String getLast_modified() {
        return last_modified;
    }

    public void setLast_modified(String last_modified) {
        this.last_modified = last_modified;
    }

    public String getLast_updated() {
        return last_updated;
    }

    public void setLast_updated(String last_updated) {
        this.last_updated = last_updated;
    }

    public String getSig_stt() {
        return sig_stt;
    }

    public void setSig_stt(String sig_stt) {
        this.sig_stt = sig_stt;
    }

    public String getGPS_stt() {
        return GPS_stt;
    }

    public void setGPS_stt(String GPS_stt) {
        this.GPS_stt = GPS_stt;
    }

    public String getMem_stt() {
        return mem_stt;
    }

    public void setMem_stt(String mem_stt) {
        this.mem_stt = mem_stt;
    }

    public String getTotal_mem() {
        return total_mem;
    }

    public void setTotal_mem(String total_mem) {
        this.total_mem = total_mem;
    }

    public String getCur_driver() {
        return cur_driver;
    }

    public void setCur_driver(String cur_driver) {
        this.cur_driver = cur_driver;
    }

    public String getCont_drv_time() {
        return cont_drv_time;
    }

    public void setCont_drv_time(String cont_drv_time) {
        this.cont_drv_time = cont_drv_time;
    }

    public String getGPS_info() {
        return GPS_info;
    }

    public void setGPS_info(String GPS_info) {
        this.GPS_info = GPS_info;
    }

    public String getSpeed() {
        return speed;
    }

    public void setSpeed(String speed) {
        this.speed = speed;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getStop_time_cfg() {
        return stop_time_cfg;
    }

    public void setStop_time_cfg(String stop_time_cfg) {
        this.stop_time_cfg = stop_time_cfg;
    }
}
