package com.mkgroup.camera.event;


/**
 * Created by doanvt on 2018/5/24.
 * Email：doanvt-hn@mk.com.vn
 */

public class AlertChangeEvent {

    public static final int TYPE_LOG_OUT = 0;
    public static final int TYPE_RECEIVE_NOTIFICATION = 1;

    private final int type;
    private final String action;

    public int getType() {
        return type;
    }

    public String getAction() {
        return action;
    }

    public AlertChangeEvent(int type, String action) {
        this.type = type;
        this.action = action;
    }

}
