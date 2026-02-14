package com.mk.autosecure.ui.clips;

/**
 * Created by DoanVT on 2017/9/15.
 */

public abstract class PositionAdjuster {
    private long mInitPosition;

    public long getAdjustedPostion(long position) {
        long adjustedPosition = position;

        if (mInitPosition == 0 && position != 0) {
            mInitPosition = position;
        }

        adjustedPosition -= mInitPosition;

        return adjustedPosition;
    }
}