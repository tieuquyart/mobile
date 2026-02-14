package com.mk.autosecure.service.job;

/**
 * Created by DoanVT on 2017/11/6.
 * Email: doanvt-hn@mk.com.vn
 */

public class UploadDataEvent {
    public enum Status {
        UPLOAD_WHAT_START,
        UPLOAD_WHAT_PROGRESS,
        UPLOAD_WHAT_FINISHED,
        UPLOAD_WHAT_ERROR
    }

    private final Status mWhat;
    private final int mExtra;


    public UploadDataEvent(Status what) {
        this(what, 0);
    }

    public UploadDataEvent(Status what, int extra) {
        this.mWhat = what;
        this.mExtra = extra;
    }

    public Status getWhat() {
        return mWhat;
    }

    public int getExtra() {
        return mExtra;
    }
}
