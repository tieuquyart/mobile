package com.mk.autosecure.rest_fleet.bean;

/**
 * Created by cloud on 2020/5/25.
 */
public class GeoFenceEventBean {
    private String geoFenceEventID;
    private String geoFenceRuleID;
    private String geoFenceTriggerType;
    private String geoFenceRuleName;

    public String getGeoFenceEventID() {
        return geoFenceEventID;
    }

    public void setGeoFenceEventID(String geoFenceEventID) {
        this.geoFenceEventID = geoFenceEventID;
    }

    public String getGeoFenceRuleID() {
        return geoFenceRuleID;
    }

    public void setGeoFenceRuleID(String geoFenceRuleID) {
        this.geoFenceRuleID = geoFenceRuleID;
    }

    public String getGeoFenceType() {
        return geoFenceTriggerType;
    }

    public void setGeoFenceType(String geoFenceType) {
        this.geoFenceTriggerType = geoFenceType;
    }

    public String getGeoFenceRuleName() {
        return geoFenceRuleName;
    }

    public void setGeoFenceRuleName(String geoFenceRuleName) {
        this.geoFenceRuleName = geoFenceRuleName;
    }

    @Override
    public String toString() {
        return "GeoFenceEventBean{" +
                "geoFenceEventID='" + geoFenceEventID + '\'' +
                ", geoFenceRuleID='" + geoFenceRuleID + '\'' +
                ", geoFenceTriggerType='" + geoFenceTriggerType + '\'' +
                ", geoFenceRuleName='" + geoFenceRuleName + '\'' +
                '}';
    }
}
