package com.mkgroup.camera.bean;

import com.google.gson.annotations.SerializedName;

import java.io.Serializable;

/**
 * Created by doanvt on 2016/10/13.
 */
public class Firmware implements Serializable {
    public long id;
    public String name;
    public String type;
    public String version;
    public String BSPVersion;
    public String url;
    public long size;
    public String md5;
    public String releaseDate;

    public Description description;

    public static class Description implements Serializable {
        public String en;
        //zh-Hans
        @SerializedName("zh-Hans")
        public String zh;
    }

    @Override
    public String toString() {
        return "Firmware{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", type='" + type + '\'' +
                ", version='" + version + '\'' +
                ", BSPVersion='" + BSPVersion + '\'' +
                ", url='" + url + '\'' +
                ", size=" + size +
                ", md5='" + md5 + '\'' +
                ", releaseDate='" + releaseDate + '\'' +
                ", description=" + description +
                '}';
    }
}
