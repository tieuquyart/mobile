package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.LastLocationBean;

import java.util.List;

public class LastLocationResponse {

    private List<LastLocationBean> cameras;

    public List<LastLocationBean> getCameras() {
        return cameras;
    }

    public void setCameras(List<LastLocationBean> cameras) {
        this.cameras = cameras;
    }

}
