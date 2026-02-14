package com.mk.autosecure.rest_fleet.bean;

/**
 * Created by cloud on 2020/5/25.
 */
public class IgnitionBean {
    /**
     * tripID : 2e6360ac-802d-439c-b46e-6d379d2a1a51
     * ignitionStatus : driving
     */

    private String tripID;
    private String ignitionStatus;

    public String getTripID() {
        return tripID;
    }

    public void setTripID(String tripID) {
        this.tripID = tripID;
    }

    public String getIgnitionStatus() {
        return ignitionStatus;
    }

    public void setIgnitionStatus(String ignitionStatus) {
        this.ignitionStatus = ignitionStatus;
    }

    @Override
    public String toString() {
        return "IgnitionBean{" +
                "tripID='" + tripID + '\'' +
                ", ignitionStatus='" + ignitionStatus + '\'' +
                '}';
    }
}
