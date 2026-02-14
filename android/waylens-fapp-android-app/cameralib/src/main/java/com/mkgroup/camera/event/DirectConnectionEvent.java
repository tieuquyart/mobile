package com.mkgroup.camera.event;

/**
 * Created by doanvt on 2019/3/14.
 * Email：doanvt-hn@mk.com.vn
 */
public class DirectConnectionEvent {

    private final int mWhat;

    public static final int WIFI_DIRECT_CONNECTED = 0;
    public static final int WIFI_DIRECT_CONNECTING = 1;
    public static final int WIFI_DIRECT_DISCONNECTED = 2;
    public static final int WIFI_DIRECT_CHANGED = 3;
    public static final int WIFI_DIRECT_CONNECTING_FAILED = 4;

    public DirectConnectionEvent(int what) {
        this.mWhat = what;
    }

    public int getWhat() {
        return mWhat;
    }

}
