package com.mk.autosecure.model;

import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.utils.DateTime;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Created by DoanVT on 2017/9/8.
 * Email: doanvt-hn@mk.com.vn
 */

public class ClipCluster {

    private List<Clip> mClipList = new ArrayList<>();
    private List<ClipSegment> mSegList = new ArrayList<>();

    public long getStartTime() {
        return startTime;
    }

    public long getDuration() {
        return duration;
    }

    private long startTime;
    private long duration;

    public ClipCluster(List<Clip> clipBeanList, long startTime, long duration, List<ClipSegment> segList) {
        mClipList = clipBeanList;
        this.startTime = startTime;
        this.duration = duration;
        this.mSegList = segList;
    }

    public List<Clip> getClipList() {
        return mClipList;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ClipCluster that = (ClipCluster) o;
        return startTime == that.startTime &&
                duration == that.duration &&
                Objects.equals(mClipList, that.mClipList) &&
                Objects.equals(mSegList, that.mSegList);
    }

    @Override
    public int hashCode() {
        return Objects.hash(mClipList, mSegList, startTime, duration);
    }

    public List<ClipSegment> getClipSegment() { return mSegList; }

    public String getDateString() {
        return DateTime.getDateStringInUTC(startTime + getClipList().get(0).getOffset());
    }


}
