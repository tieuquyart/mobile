package com.mk.autosecure.rest.reponse;

import com.mkgroup.camera.bean.Alert;

import java.util.List;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class AlertListResponse {

    public List<Alert> alerts;
    public Boolean hasMore;
    public Integer unreadCount;

    @Override
    public String toString() {
        return "AlertListResponse{" +
                "alerts=" + alerts +
                ", hasMore=" + hasMore +
                ", unreadCount=" + unreadCount +
                '}';
    }
}
