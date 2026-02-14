package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.StatisticBean;

import java.util.List;

public class StatisticResponse {

    /**
     * vehicleNumber : 10
     * activeVehicleNumber : 2
     * statisticList : [{"from":1571551200000,"to":1571637600000,"mileage":3202,"duration":16994,"event":2},{"from":1571637600000,"to":1571639521000,"mileage":0,"duration":0,"event":0}]
     */

    private int vehicleNumber;
    private int activeVehicleNumber;
    private List<StatisticBean> statisticList;

    public int getVehicleNumber() {
        return vehicleNumber;
    }

    public void setVehicleNumber(int vehicleNumber) {
        this.vehicleNumber = vehicleNumber;
    }

    public int getActiveVehicleNumber() {
        return activeVehicleNumber;
    }

    public void setActiveVehicleNumber(int activeVehicleNumber) {
        this.activeVehicleNumber = activeVehicleNumber;
    }

    public List<StatisticBean> getStatisticList() {
        return statisticList;
    }

    public void setStatisticList(List<StatisticBean> statisticList) {
        this.statisticList = statisticList;
    }

}
