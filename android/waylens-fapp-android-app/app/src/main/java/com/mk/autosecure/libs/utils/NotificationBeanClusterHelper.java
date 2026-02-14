package com.mk.autosecure.libs.utils;

import com.mk.autosecure.rest_fleet.bean.NotificationBean;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

public class NotificationBeanClusterHelper {

    private final static String TAG = NotificationBeanClusterHelper.class.getSimpleName();

    private List<NotificationBean> beanList;

    private SimpleDateFormat dateFormat;

    private Map<String, List<NotificationBean>> dayTimeline = new HashMap<>();

    public NotificationBeanClusterHelper(List<NotificationBean> beanList) {
        this.beanList = beanList;

//        FleetUser fleetUser = HornApplication.getComponent().currentUser().getFleetUser();
        TimeZone timeZone = TimeZone.getDefault();

        dateFormat = new SimpleDateFormat("MMMM dd, yyyy", Locale.getDefault());
        dateFormat.setTimeZone(timeZone);
    }

    public List<List<NotificationBean>> getClusterList() {
        ArrayList<NotificationBean> timelineBeans = new ArrayList<>(beanList);

        for (NotificationBean bean : timelineBeans) {
//            long timelineTime = bean.getNotificationTime();
//            String date = dateFormat.format(new Date(timelineTime));
//            putTimeline(date, bean);
        }

        return new ArrayList<>(dayTimeline.values());
    }

    private void putTimeline(String date, NotificationBean bean) {
        List<NotificationBean> timelineBeans = dayTimeline.get(date);
        if (timelineBeans == null) {
            timelineBeans = new ArrayList<>();
        }
        timelineBeans.add(bean);
        dayTimeline.put(date, timelineBeans);
    }
}
