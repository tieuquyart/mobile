package com.mk.autosecure.ui.clips;

import com.mkgroup.camera.model.VdbUrl;

/**
 * Created by DoanVT on 2017/9/15.
 */

public class ClipPositionAdjuster extends PositionAdjuster {
    private static final String TAG = ClipPositionAdjuster.class.getSimpleName();
    private final VdbUrl mUrl;
    private final long mStartTimeMs;

    public ClipPositionAdjuster(long startTime, VdbUrl url) {
        this.mStartTimeMs = startTime;
        this.mUrl = url;
    }

    @Override
    public long getAdjustedPostion(long position) {
        long adjustedPosition = super.getAdjustedPostion(position);

        adjustedPosition += mUrl.realTimeMs - mStartTimeMs;

        return adjustedPosition;

    }
}
