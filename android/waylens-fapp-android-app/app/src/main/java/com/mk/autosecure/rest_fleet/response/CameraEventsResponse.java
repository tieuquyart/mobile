package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.CameraEventBean;

import java.util.List;

public class CameraEventsResponse extends Response {


    private List<CameraEventBean> data;

    public List<CameraEventBean> getEvents() {
        return data;
    }

    public void setEvents(List<CameraEventBean> events) {
        this.data = events;
    }

    @Override
    public String toString() {
        return "CameraEventsResponse{" +
                "data=" + data +
                '}';
    }
}
