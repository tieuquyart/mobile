package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.AppLastVersionBean;

public class AppLastVersionResponse extends Response {
    public AppLastVersionBean data;


    @Override
    public String toString() {
        return "AppLastVersionResponse{" +
                "data=" + data +
                '}';
    }
}
