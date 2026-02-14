package com.mk.autosecure.model;

import com.mk.autosecure.rest_fleet.bean.EventBean;

import java.util.Objects;

/**
 * Created by DoanVT on 2017/9/21.
 */

public class EventBeanPos {
    public long offset;
    private EventBean eventBean;

    public EventBean getEventBean() {
        return eventBean;
    }

    public long getOffset() {
        return offset;
    }

    public EventBeanPos(EventBean eventBean, long offset) {
        this.eventBean = eventBean;
        this.offset = offset;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        EventBeanPos that = (EventBeanPos) o;
        return offset == that.offset &&
                Objects.equals(eventBean, that.eventBean);
    }

    @Override
    public int hashCode() {
        return Objects.hash(offset, eventBean);
    }
}
