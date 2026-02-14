package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;

import java.util.List;

public class DriverListResponse extends  Response{
    private List<DriverInfoBean> data;

    public List<DriverInfoBean> getData() {
        return data;
    }

    public void setData(List<DriverInfoBean> data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "DriverListResponse{" +
                "data=" + data +
                '}';
    }
}
