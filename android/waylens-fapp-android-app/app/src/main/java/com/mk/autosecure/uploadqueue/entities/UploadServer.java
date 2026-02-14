package com.mk.autosecure.uploadqueue.entities;


import com.mkgroup.camera.utils.ToStringUtils;

import java.io.Serializable;

/**
 * Created by doanvt on 2016/4/27.
 */
public class UploadServer implements Serializable {
    public String ip;
    public int port;
    public String privateKey;
    public String url;


    public UploadServer(String address, int port, String privateKey) {
        this.ip = address;
        this.port = port;
        this.privateKey = privateKey;
    }


    @Override
    public String toString() {
        return ToStringUtils.getString(this);
    }
}
