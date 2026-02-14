package com.mk.autosecure.rest_fleet.request;

public class ModifyPwdBody {

    public String oldPassword;

    public String newPassword;

    public String newPasswordAgain;

    public ModifyPwdBody(String oldPassword, String newPassword, String newPasswordAgain) {
        this.oldPassword = oldPassword;
        this.newPassword = newPassword;
        this.newPasswordAgain = newPasswordAgain;
    }
}
