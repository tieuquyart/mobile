package com.mk.autosecure.rest.request;

public class CheckSerialBody {

    public String serial;

    public CheckSerialBody(String serial) {
        this.serial = serial;
    }

    @Override
    public String toString() {
        return "CheckSerialBody{" +
                "serial='" + serial + '\'' +
                '}';
    }
}
