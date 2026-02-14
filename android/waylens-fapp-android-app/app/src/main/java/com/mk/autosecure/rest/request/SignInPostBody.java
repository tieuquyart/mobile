package com.mk.autosecure.rest.request;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class SignInPostBody {
    public String email;
    public String password;
    public String appToken;
    public String deviceName;

    public SignInPostBody(String email, String password, String appToken, String deviceName) {
        this.email = email;
        this.password = password;
        this.appToken = appToken;
        this.deviceName = deviceName;
    }
}
