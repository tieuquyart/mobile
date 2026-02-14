package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.NotificationBean;

public class NotificationInfoResponse extends Response {

    private NotificationBean data;

    public NotificationBean getData() {
        return data;
    }

    public void setData(NotificationBean data) {
        this.data = data;
    }

}
