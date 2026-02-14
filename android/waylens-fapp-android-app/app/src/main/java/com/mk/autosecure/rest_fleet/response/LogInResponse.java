package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.UserLogin;

public class LogInResponse extends Response {

    private UserLogin data;

    public UserLogin getUserLogin() {
        return data;
    }

    public void setData(UserLogin data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "LogInResponse{" +
                ", token='" + data.getToken() + '\'' +
                ", data=" + data +
                '}';
    }
}
