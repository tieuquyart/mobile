package com.mkgroup.camera.event;


/**
 * Created by doanvt on 2018/5/24.
 * Email：doanvt-hn@mk.com.vn
 */

public class SettingChangeEvent {

    public final static String ACTION_START = "start";
    public final static String ACTION_SUCCESS = "success";
    public final static String ACTION_FAILURE = "failure";

    private final boolean isUpdated;
    private final String action;

    public boolean isUpdated() {
        return isUpdated;
    }

    public String getAction() {
        return action;
    }

    public SettingChangeEvent(String action, boolean isUpdated) {
        this.action = action;
        this.isUpdated = isUpdated;
    }

}
