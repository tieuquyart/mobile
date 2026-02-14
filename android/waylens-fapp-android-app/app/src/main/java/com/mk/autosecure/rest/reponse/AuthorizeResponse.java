package com.mk.autosecure.rest.reponse;

import com.mk.autosecure.rest.bean.UserBean;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class AuthorizeResponse {
    public UserBean user;

    public String token;

    public Long expiredTime;

    @Override
    public String toString() {
        return "AuthorizeResponse{" +
                "user=" + user +
                ", token='" + token + '\'' +
                ", expiredTime=" + expiredTime +
                '}';
    }
}