package com.mk.autosecure.model;

import com.mkgroup.camera.bean.ClipBean;
import com.mkgroup.camera.utils.DateTime;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by DoanVT on 2017/9/4.
 */

public class ClipBeanCluster {

    private List<ClipBean> mClipBeanList = new ArrayList<>();
    private List<ClipSegment> mSegList = new ArrayList<>();

    private long startTime;
    private long duration;

    public long getStartTime() {
        return startTime;
    }

    public long getDuration() {
        return duration;
    }

    public ClipBeanCluster(List<ClipBean> clipBeanList, long startTime, long duration, List<ClipSegment> segList) {
        mClipBeanList = clipBeanList;
        this.startTime = startTime;
        this.duration = duration;
        this.mSegList = segList;
    }

    public List<ClipBean> getClipBeanList() {
        return mClipBeanList;
    }

    public List<ClipSegment> getClipSegment() {
        return mSegList;
    }

    public String getDateString() {
        return DateTime.getDateStringInUTC(startTime);
//        return DateTime.getDateStringInUTC(startTime + getClipBeanList().get(0).getOffset());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ClipBeanCluster that = (ClipBeanCluster) o;

        if (startTime != that.startTime) return false;
        if (duration != that.duration) return false;
        if (mClipBeanList != null ? !mClipBeanList.equals(that.mClipBeanList) : that.mClipBeanList != null)
            return false;
        return mSegList != null ? mSegList.equals(that.mSegList) : that.mSegList == null;
    }

    @Override
    public int hashCode() {
        int result = mClipBeanList != null ? mClipBeanList.hashCode() : 0;
        result = 31 * result + (mSegList != null ? mSegList.hashCode() : 0);
        result = 31 * result + (int) (startTime ^ (startTime >>> 32));
        result = 31 * result + (int) (duration ^ (duration >>> 32));
        return result;
    }

    @Override
    public String toString() {
        return "ClipBeanCluster{" +
                "mClipBeanList=" + mClipBeanList +
                ", mSegList=" + mSegList +
                ", startTime=" + startTime +
                ", duration=" + duration +
                '}';
    }
}