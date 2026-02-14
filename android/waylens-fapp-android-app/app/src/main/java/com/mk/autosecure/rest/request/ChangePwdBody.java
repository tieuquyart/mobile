package com.mk.autosecure.rest.request;

/**
 * Created by DoanVT on 2017/11/8.
 * Email: doanvt-hn@mk.com.vn
 */

public class ChangePwdBody {
    public String curPassword;
    public String newPassword;

    public ChangePwdBody(String curPassword, String newPassword) {
        this.curPassword = curPassword;
        this.newPassword = newPassword;
    }
}
