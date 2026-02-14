package com.mkgroup.camera.model.fms;

public class SendDataFWResponse {
    private int code;
    private String msg;
    private boolean success;
    private Object data;

    public SendDataFWResponse(int code, String msg, boolean success, Object data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
        this.success = success;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

    public int getCode() {
        return code;
    }

    public void setCode(int code) {
        this.code = code;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }
}
