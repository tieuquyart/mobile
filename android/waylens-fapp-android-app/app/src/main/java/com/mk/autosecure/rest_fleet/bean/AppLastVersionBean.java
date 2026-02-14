package com.mk.autosecure.rest_fleet.bean;

public class AppLastVersionBean {
    public int versionCode;
    public String versionName;
    public boolean forceUpdate;
    public String pushDevice;
    public String storeUrl;

    @Override
    public String toString() {
        return "AppLastVersionBean{" +
                "versionCode='" + versionCode + '\'' +
                ", versionName='" + versionName + '\'' +
                ", forceUpdate=" + forceUpdate +
                ", pushDevice='" + pushDevice + '\'' +
                ", storeUrl='" + storeUrl + '\'' +
                '}';
    }
}
