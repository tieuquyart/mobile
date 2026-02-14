package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.StatisticBean;

import java.util.List;

public class DashDriverResponse {

    private List<StatisticBean> statisticList;

    public List<StatisticBean> getStatisticList() {
        return statisticList;
    }

    public void setStatisticList(List<StatisticBean> statisticList) {
        this.statisticList = statisticList;
    }

}
