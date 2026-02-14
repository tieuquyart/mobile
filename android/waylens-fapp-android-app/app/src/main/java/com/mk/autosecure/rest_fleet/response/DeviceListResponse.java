package com.mk.autosecure.rest_fleet.response;

import com.mkgroup.camera.bean.FleetCameraBean;

import java.util.List;

public class DeviceListResponse extends Response{
    private List<FleetCameraBean> data;

    public List<FleetCameraBean> getData() {
        return data;
    }

    public void setData(List<FleetCameraBean> data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "DeviceListResponse{" +
                "data=" + data +
                '}';
    }
}
