package com.mk.autosecure.model;

import com.mkgroup.camera.model.ClipPos;

/**
 * Created by DoanVT on 2017/9/12.
 * Email: doanvt-hn@mk.com.vn
 */

public class ClipPosChangeEvent {
    private final String mPublisher;
    private final ClipPos mClipPos;
    private final int mIntent;

    public static final int INTENT_LIVE = 0;
    public static final int INTENT_PLAY = 1;
    public static final int INTENT_SHOW_THUMBNAIL = 2;
    public static final int INTENT_PLAY_END = 3;

    public ClipPosChangeEvent(ClipPos clipPos, String publisher) {
        this(clipPos, publisher, INTENT_PLAY);
    }

    public ClipPosChangeEvent(ClipPos clipPos, String publisher, int intent) {
        this.mClipPos = clipPos;
        this.mPublisher = publisher;
        this.mIntent = intent;
    }

    public ClipPos getClipPos() {
        return mClipPos;
    }

    public String getPublisher() {
        return mPublisher;
    }

    public int getIntent() {
        return mIntent;
    }
}
