package com.mkgroup.camera.message.bean;

import java.io.Serializable;

/**
 * Created by cloud on 2021/1/16.
 */
public class HotspotInfoModel implements Serializable {

    private String ssid;
    private String key;

    public HotspotInfoModel(String ssid, String key) {
        this.ssid = ssid;
        this.key = key;
    }

    public String getSsid() {
        return ssid;
    }

    public void setSsid(String ssid) {
        this.ssid = ssid;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    @Override
    public String toString() {
        return "HotspotInfoModel{" +
                "ssid='" + ssid + '\'' +
                ", key='" + key + '\'' +
                '}';
    }
}
