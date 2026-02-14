package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.StatisticListBean;

import java.util.List;

public class SummaryClipResponse {

    private List<StatisticListBean> statisticList;

    public List<StatisticListBean> getStatisticList() {
        return statisticList;
    }

    public void setStatisticList(List<StatisticListBean> statisticList) {
        this.statisticList = statisticList;
    }

    @Override
    public String toString() {
        return "SummaryClipResponse{" +
                "statisticList=" + statisticList +
                '}';
    }
}
