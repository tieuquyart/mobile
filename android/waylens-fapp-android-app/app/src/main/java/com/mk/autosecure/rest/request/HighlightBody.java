package com.mk.autosecure.rest.request;

import java.io.Serializable;

/**
 * Created by DoanVT on 2017/9/1.
 */

public class HighlightBody implements Serializable {
    public String videoServer;
    public String deviceID;
    public String streamID;
    public Long startTime;
    public Long duration;

    public HighlightBody(String deviceID, String streamID, Long startTime, Long duration) {
        this.videoServer = "ali.oss";
        this.deviceID = deviceID;
        this.streamID = streamID;
        this.startTime = startTime;
        this.duration = duration;
    }
}
