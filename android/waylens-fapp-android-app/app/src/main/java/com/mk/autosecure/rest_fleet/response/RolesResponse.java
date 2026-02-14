package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.RoleBean;

import java.util.List;

public class RolesResponse {
    private String code;
    private String message;
    private boolean success;
    private List<RoleBean> data;

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public List<RoleBean> getData() {
        return data;
    }

    public void setData(List<RoleBean> data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "RolesResponse{" +
                "code='" + code + '\'' +
                ", message='" + message + '\'' +
                ", success=" + success +
                ", data=" + data +
                '}';
    }
}
