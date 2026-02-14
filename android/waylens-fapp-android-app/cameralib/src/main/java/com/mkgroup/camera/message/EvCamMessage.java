package com.mkgroup.camera.message;

public class EvCamMessage {
    public final String category;
    public final String msg;
    public final String body;

    public EvCamMessage(String category, String msg, String body) {
        this.category = category;
        this.msg = msg;
        this.body = body;
    }

    @Override
    public String toString() {
        return "EvCamMessage{" +
                "category='" + category + '\'' +
                ", msg='" + msg + '\'' +
                ", body=" + body +
                '}';
    }
}
