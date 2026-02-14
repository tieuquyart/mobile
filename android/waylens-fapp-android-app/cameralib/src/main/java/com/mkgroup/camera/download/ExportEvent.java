package com.mkgroup.camera.download;

import com.mkgroup.camera.db.VideoItem;

/**
 * Created by DoanVT on 2017/12/22.
 * Email: doanvt-hn@mk.com.vn
 */
public class ExportEvent {

    public static final int EVENT_TYPE_INIT = 0;
    public static final int EVENT_TYPE_PROCESS = 1;
    public static final int EVENT_TYPE_END = 2;

    private final ExportableJob job;
    private final int type;
    private VideoItem videoItem;
    private String symbol;

    public ExportEvent(String symbol, ExportableJob job, int type) {
        this.symbol = symbol;
        this.job = job;
        this.type = type;
    }

    public VideoItem getVideoItem() {
        return videoItem;
    }

    public void setVideoItem(VideoItem videoItem) {
        this.videoItem = videoItem;
    }

    public int getType() {
        return type;
    }

    public ExportableJob getJob() {
        return job;
    }

    public String getSymbol() {
        return symbol;
    }
}