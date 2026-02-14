package com.mk.autosecure.model;

/**
 * Created by DoanVT on 2017/9/21.
 */

public class EventBeanPosChangeEvent {
    private final String mPublisher;
    private final EventBeanPos mClipBeanPos;
    private final int mIntent;

    public static final int INTENT_LIVE = 0;
    public static final int INTENT_PLAY = 1;
    public static final int INTENT_SHOW_THUMBNAIL = 2;
    public static final int INTENT_PLAY_END = 3;

    public EventBeanPosChangeEvent(EventBeanPos clipPos, String publisher) {
        this(clipPos, publisher, INTENT_PLAY);
    }

    public EventBeanPosChangeEvent(EventBeanPos clipPos, String publisher, int intent) {
        this.mClipBeanPos = clipPos;
        this.mPublisher = publisher;
        this.mIntent = intent;
    }

    public EventBeanPos getClipBeanPos() {
        return mClipBeanPos;
    }

    public String getPublisher() {
        return mPublisher;
    }

    public int getIntent() {
        return mIntent;
    }
}
