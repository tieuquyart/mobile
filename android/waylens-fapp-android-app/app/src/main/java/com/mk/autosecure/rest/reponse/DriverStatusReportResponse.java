package com.mk.autosecure.rest.reponse;

import com.mk.autosecure.rest_fleet.bean.DetailBean;
import com.mk.autosecure.rest_fleet.bean.EventListBean;
import com.mk.autosecure.rest_fleet.bean.HoursListBean;
import com.mk.autosecure.rest_fleet.response.Response;

import java.util.List;

public class DriverStatusReportResponse extends Response {

    private Data data;

    public Data getData() {
        return data;
    }

    public void setData(Data data) {
        this.data = data;
    }

    public class Data{
        private double driverTotal;
        private DetailBean driversList;
        private double eventTotal;
        private List<EventListBean> eventsList;
        private List<HoursListBean> hoursList;
        private double hoursTotal;
        private List<HoursListBean> milesList;
        private double milesTotal;
        private DetailBean vehicleList;
        private double vehicleTotal;

        public double getDriverTotal() {
            return driverTotal;
        }

        public void setDriverTotal(double driverTotal) {
            this.driverTotal = driverTotal;
        }

        public DetailBean getDriversList() {
            return driversList;
        }

        public void setDriversList(DetailBean driversList) {
            this.driversList = driversList;
        }

        public double getEventTotal() {
            return eventTotal;
        }

        public void setEventTotal(double eventTotal) {
            this.eventTotal = eventTotal;
        }

        public List<EventListBean> getEventsList() {
            return eventsList;
        }

        public void setEventsList(List<EventListBean> eventsList) {
            this.eventsList = eventsList;
        }

        public List<HoursListBean> getHoursList() {
            return hoursList;
        }

        public void setHoursList(List<HoursListBean> hoursList) {
            this.hoursList = hoursList;
        }

        public double getHoursTotal() {
            return hoursTotal;
        }

        public void setHoursTotal(double hoursTotal) {
            this.hoursTotal = hoursTotal;
        }

        public List<HoursListBean> getMilesList() {
            return milesList;
        }

        public void setMilesList(List<HoursListBean> milesList) {
            this.milesList = milesList;
        }

        public double getMilesTotal() {
            return milesTotal;
        }

        public void setMilesTotal(double milesTotal) {
            this.milesTotal = milesTotal;
        }

        public DetailBean getVehicleList() {
            return vehicleList;
        }

        public void setVehicleList(DetailBean vehicleList) {
            this.vehicleList = vehicleList;
        }

        public double getVehicleTotal() {
            return vehicleTotal;
        }

        public void setVehicleTotal(double vehicleTotal) {
            this.vehicleTotal = vehicleTotal;
        }
    }
}
