package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.TripBean;

import java.util.List;

public class TripsResponse extends Response {

    private List<TripBean> data;

    public List<TripBean> getTrips() {
        return data;
    }

    public void setTrips(List<TripBean> trips) {
        this.data = trips;
    }

}
