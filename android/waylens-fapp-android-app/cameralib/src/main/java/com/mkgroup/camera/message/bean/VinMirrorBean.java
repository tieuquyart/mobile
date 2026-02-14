package com.mkgroup.camera.message.bean;

import java.util.List;

public class VinMirrorBean {

    private List<String> vinMirrorList;

    public VinMirrorBean(List<String> vinMirrorList) {
        this.vinMirrorList = vinMirrorList;
    }

    public List<String> getVinMirrorList() {
        return vinMirrorList;
    }

    public void setVinMirrorList(List<String> vinMirrorList) {
        this.vinMirrorList = vinMirrorList;
    }
}
