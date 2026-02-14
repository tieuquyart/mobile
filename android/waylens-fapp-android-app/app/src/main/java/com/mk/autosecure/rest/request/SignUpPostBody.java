package com.mk.autosecure.rest.request;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class SignUpPostBody {
    public String email;
    public String fleetName;
    public String password;
    public String mobile;
    public String realName;
    public String userName;

    public SignUpPostBody(String email, String fleetName, String password, String mobile, String realName, String userName) {
        this.email = email;
        this.fleetName = fleetName;
        this.password = password;
        this.mobile = mobile;
        this.realName = realName;
        this.userName = userName;
    }

    @Override
    public String toString() {
        return "SignUpPostBody{" +
                "email='" + email + '\'' +
                ", fleetName='" + fleetName + '\'' +
                ", password='" + password + '\'' +
                ", mobile='" + mobile + '\'' +
                ", realName='" + realName + '\'' +
                ", userName='" + userName + '\'' +
                '}';
    }
}