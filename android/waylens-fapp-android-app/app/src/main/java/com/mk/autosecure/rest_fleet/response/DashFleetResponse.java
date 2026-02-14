package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.FleetViewBean;

import java.util.List;

public class DashFleetResponse {

    private List<FleetViewBean> statisticList;

    public List<FleetViewBean> getStatisticList() {
        return statisticList;
    }

    public void setStatisticList(List<FleetViewBean> statisticList) {
        this.statisticList = statisticList;
    }

}
