package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.TimelineBean;

import java.util.List;

public class TimelineResponse {

    private List<TimelineBean> timeline;

    public List<TimelineBean> getTimeline() {
        return timeline;
    }

    public void setTimeline(List<TimelineBean> timeline) {
        this.timeline = timeline;
    }
}
