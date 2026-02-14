package com.mkgroup.camera.event;


/**
 * Created by doanvt on 2018/5/24.
 * Email：doanvt-hn@mk.com.vn
 */

public class MessageChangeEvent {

    public static final int TYPE_RECEIVE_MESSAGE = 0;

    private final int type;
    private final String action;

    public int getType() {
        return type;
    }

    public String getAction() {
        return action;
    }

    public MessageChangeEvent(int type, String action) {
        this.type = type;
        this.action = action;
    }

}
