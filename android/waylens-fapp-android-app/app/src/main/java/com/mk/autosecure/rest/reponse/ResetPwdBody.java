package com.mk.autosecure.rest.reponse;

/**
 * Created by DoanVT on 2017/11/7.
 * Email: doanvt-hn@mk.com.vn
 */

public class ResetPwdBody {
    public String userName;
    public String email;
    public String mobile;

    public ResetPwdBody(String account, String email, String phone) {
        this.userName = account;
        this.email = email;
        this.mobile = phone;
    }

    @Override
    public String toString() {
        return "ResetPwdBody{" +
                "account='" + userName + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + mobile + '\'' +
                '}';
    }
}
