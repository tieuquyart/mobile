package com.mkgroup.camera.message;

/**
 * Created by DoanVT on 2017/7/27.
 */

public class VdtMessage {
    public final int domain;
    public final int messageType;
    public final String parameter1;
    public final String parameter2;

    public VdtMessage(int domain, int messageType, String parameter1, String parameter2) {
        this.domain = domain;
        this.messageType = messageType;
        this.parameter1 = parameter1;
        this.parameter2 = parameter2;
    }

    @Override
    public String toString() {
        return "VdtMessage{" +
                "domain=" + domain +
                ", messageType=" + messageType +
                ", parameter1='" + parameter1 + '\'' +
                ", parameter2='" + parameter2 + '\'' +
                '}';
    }
}
