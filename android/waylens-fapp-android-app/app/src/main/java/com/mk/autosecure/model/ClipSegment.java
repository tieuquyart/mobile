package com.mk.autosecure.model;

import com.mkgroup.camera.model.Clip;

import java.util.Objects;

/**
 * Created by DoanVT on 2017/9/11.
 */

public class ClipSegment {
    public long startTime;
    public long duration;
    public int types = -1;
    //display ratio in seek bar
    public int ratio;
    public boolean startSeg; // 从上到下的顺序，同优先级，时间线靠前的在出现在UI上层
    public Object data;
    public boolean isCloud;

    public long getLength() {
        return ratio * duration;
    }

    public ClipSegment(long startTime, long duration, int types, Object data) {
        this(startTime, duration, types, data, true, false);
    }

    public ClipSegment(long startTime, long duration, int types, Object data, boolean startSeg, boolean isCloud) {
        this.startTime = startTime;
        this.duration = duration;
        this.types = types;
        if (types == Clip.TYPE_BUFFERED) {
            ratio = 1;
        } else {
            ratio = 8;
        }
        this.data = data;
        this.isCloud = isCloud;
        this.startSeg = startSeg;
    }

    public long getStartTime() {
        return startTime;
    }

    public long getEndTime() {
        return startTime + duration;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ClipSegment that = (ClipSegment) o;
        return startTime == that.startTime &&
                duration == that.duration &&
                types == that.types &&
                ratio == that.ratio &&
                startSeg == that.startSeg &&
                isCloud == that.isCloud &&
                Objects.equals(data, that.data);
    }

    @Override
    public int hashCode() {
        return Objects.hash(startTime, duration, types, ratio, startSeg, data, isCloud);
    }
}