package com.mkgroup.camera.message.bean;

public class ServerUrlBean {

    /**
     * url : wss://tscastle.cam2cloud.com:9002/api/4g/
     */

    private String url;

    public ServerUrlBean(String url) {
        this.url = url;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}
