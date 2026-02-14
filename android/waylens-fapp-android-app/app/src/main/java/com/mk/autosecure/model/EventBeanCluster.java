package com.mk.autosecure.model;

import com.mkgroup.camera.utils.DateTime;
import com.mk.autosecure.rest_fleet.bean.EventBean;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Created by DoanVT on 2017/9/4.
 */

public class EventBeanCluster {

    private List<EventBean> mEventBeanList = new ArrayList<>();
    private List<ClipSegment> mSegList = new ArrayList<>();

    private long startTime;
    private long duration;

    public long getStartTime() {
        return startTime;
    }

    public long getDuration() {
        return duration;
    }

    public EventBeanCluster(List<EventBean> clipBeanList, long startTime, long duration, List<ClipSegment> segList) {
        mEventBeanList = clipBeanList;
        this.startTime = startTime;
        this.duration = duration;
        this.mSegList = segList;
    }

    public List<EventBean> getEventBeanList() {
        return mEventBeanList;
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
        EventBeanCluster that = (EventBeanCluster) o;
        return startTime == that.startTime &&
                duration == that.duration &&
                Objects.equals(mEventBeanList, that.mEventBeanList) &&
                Objects.equals(mSegList, that.mSegList);
    }

    @Override
    public int hashCode() {
        return Objects.hash(mEventBeanList, mSegList, startTime, duration);
    }

    @Override
    public String toString() {
        return "EventBeanCluster{" +
                "mEventBeanList=" + mEventBeanList +
                ", mSegList=" + mSegList +
                ", startTime=" + startTime +
                ", duration=" + duration +
                '}';
    }
}