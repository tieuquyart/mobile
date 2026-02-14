package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.NotificationBean;

import java.util.ArrayList;

public class NotificationResponse extends Response {

    private ArrayList<NotificationBean> data;

    public ArrayList<NotificationBean> getData() {
        return data;
    }

    public void setData(ArrayList<NotificationBean> data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "NotificationResponse{" +
//                "success=" + success +
//                ", code='" + code + '\'' +
//                ", message=" + message +
                ", data=" + data +
                '}';
    }

}
