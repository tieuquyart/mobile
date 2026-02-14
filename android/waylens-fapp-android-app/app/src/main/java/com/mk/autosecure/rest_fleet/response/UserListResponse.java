package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.UsersBean;

import java.util.List;

public class UserListResponse {
    private String code;
    private String message;
    private Boolean success;
    private List<UsersBean> data;

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

    public Boolean getSuccess() {
        return success;
    }

    public void setSuccess(Boolean success) {
        this.success = success;
    }

    public List<UsersBean> getData() {
        return data;
    }

    public void setData(List<UsersBean> data) {
        this.data = data;
    }

    @Override
    public String toString() {
        return "UserListResponse{" +
                "code='" + code + '\'' +
                ", message='" + message + '\'' +
                ", success=" + success +
                ", data=" + data +
                '}';
    }
}


