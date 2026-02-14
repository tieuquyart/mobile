package com.mk.autosecure.rest_fleet.request;

public class LogInPostBody {

    public String username;
    public String password;

    public LogInPostBody(String username, String password) {
        this.username = username;
        this.password = password;
    }

}
