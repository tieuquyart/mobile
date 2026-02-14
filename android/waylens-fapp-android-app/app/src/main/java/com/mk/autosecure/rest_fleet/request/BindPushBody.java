package com.mk.autosecure.rest_fleet.request;

public class BindPushBody {
    public String deviceType;
    public String registrationId;

    public BindPushBody(String deviceType, String registrationId) {
        this.deviceType = deviceType;
        this.registrationId = registrationId;
    }
}
