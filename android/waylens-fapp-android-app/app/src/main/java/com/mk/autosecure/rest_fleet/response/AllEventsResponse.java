package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.EventBean;

import java.io.Serializable;
import java.util.List;

public class AllEventsResponse implements Serializable {

    private List<EventBean> events;

    private boolean hasMore;

    public List<EventBean> getEvents() {
        return events;
    }

    public void setEvents(List<EventBean> events) {
        this.events = events;
    }

    public boolean isHasMore() {
        return hasMore;
    }

    public void setHasMore(boolean hasMore) {
        this.hasMore = hasMore;
    }

    @Override
    public String toString() {
        return "AllEventsResponse{" +
                "events=" + events +
                ", hasMore=" + hasMore +
                '}';
    }
}
