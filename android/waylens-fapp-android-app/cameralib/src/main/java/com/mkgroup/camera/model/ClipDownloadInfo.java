package com.mkgroup.camera.model;

/**
 * Created by DoanVT on 2017/9/28.
 */


import java.io.Serializable;

public class ClipDownloadInfo {

    public static class StreamDownloadInfo implements Serializable {
        public int clipDate;
        public long clipTimeMs;
        public int lengthMs;
        public long size;
        public String url;
    }

    public final Clip.ID cid;
    public int opt;
    public final StreamDownloadInfo main = new StreamDownloadInfo();
    public final StreamDownloadInfo sub = new StreamDownloadInfo();
    public final StreamDownloadInfo subN = new StreamDownloadInfo();
    public byte[] posterData;

    public ClipDownloadInfo(Clip.ID cid) {
        this.cid = cid;
    }
}