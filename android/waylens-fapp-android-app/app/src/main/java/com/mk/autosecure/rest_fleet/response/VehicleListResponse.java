package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;

import java.util.List;

public class VehicleListResponse extends Response{
    private List<VehicleInfoBean> data;

    public List<VehicleInfoBean> getData() {
        return data;
    }

    public void setData(List<VehicleInfoBean> data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "VehicleListResponse{" +
                "data=" + data +
                '}';
    }
}
