package com.mk.autosecure.rest_fleet.request;

public class PhoneNoBody {
    private String serial;
    private String phone;
    private String notificationId;

    public PhoneNoBody(String serial, String phone, String notificationId) {
        this.serial = serial;
        this.phone = phone;
        this.notificationId = notificationId;
    }

    public String getSerial() {
        return serial;
    }

    public void setSerial(String serial) {
        this.serial = serial;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(String notificationId) {
        this.notificationId = notificationId;
    }
}
