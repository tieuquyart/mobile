package com.mk.autosecure.libs.utils;

import com.mk.autosecure.rest_fleet.bean.TimelineBean;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

public class TimelineBeanClusterHelper {

    private final static String TAG = TimelineBeanClusterHelper.class.getSimpleName();

    private List<TimelineBean> beanList;

    private SimpleDateFormat dateFormat;

    private Map<String, List<TimelineBean>> dayTimeline = new HashMap<>();

    public TimelineBeanClusterHelper(List<TimelineBean> beanList) {
        this.beanList = beanList;

//        FleetUser fleetUser = HornApplication.getComponent().currentUser().getFleetUser();
        TimeZone timeZone =  TimeZone.getDefault();

        dateFormat = new SimpleDateFormat("MMMM dd, yyyy", Locale.getDefault());
        dateFormat.setTimeZone(timeZone);
    }

    public List<List<TimelineBean>> getClusterList() {
        ArrayList<TimelineBean> timelineBeans = new ArrayList<>(beanList);

        for (TimelineBean bean : timelineBeans) {
            long timelineTime = bean.getTimelineTime();
            String date = dateFormat.format(new Date(timelineTime));
            putTimeline(date, bean);
        }

        return new ArrayList<>(dayTimeline.values());
    }

    private void putTimeline(String date, TimelineBean bean) {
        List<TimelineBean> timelineBeans = dayTimeline.get(date);
        if (timelineBeans == null) {
            timelineBeans = new ArrayList<>();
        }
        timelineBeans.add(bean);
        dayTimeline.put(date, timelineBeans);
    }
}
