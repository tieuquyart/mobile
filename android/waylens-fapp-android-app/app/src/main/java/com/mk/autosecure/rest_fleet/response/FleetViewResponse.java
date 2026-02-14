package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.FleetViewBean;

public class FleetViewResponse extends Response {
    private FleetViewBean data;

    public FleetViewBean getData() {
        return data;
    }

    public void setData(FleetViewBean data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "FleetViewResponse{" +
                "data=" + data +
                '}';
    }
}
