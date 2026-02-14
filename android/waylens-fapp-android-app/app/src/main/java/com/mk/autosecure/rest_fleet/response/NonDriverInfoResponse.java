package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.NonDriverInfoBean;

import java.util.List;

public class NonDriverInfoResponse {

    private List<NonDriverInfoBean> userInfos;

    public List<NonDriverInfoBean> getUserInfos() {
        return userInfos;
    }

    public void setUserInfos(List<NonDriverInfoBean> userInfos) {
        this.userInfos = userInfos;
    }

}
