package com.mk.autosecure.rest_fleet.request;

public class UserBody {
    public String userName;
    public String realName;

    public UserBody(String userName, String realName) {
        this.userName = userName;
        this.realName = realName;
    }
}
