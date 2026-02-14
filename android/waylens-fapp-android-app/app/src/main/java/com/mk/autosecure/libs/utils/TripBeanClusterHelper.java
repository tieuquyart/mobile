package com.mk.autosecure.libs.utils;


import com.mk.autosecure.rest_fleet.bean.TripBean;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

public class TripBeanClusterHelper {
    private final static String TAG = TripBeanClusterHelper.class.getSimpleName();

    private List<TripBean> beanList;

    private SimpleDateFormat dateFormat;

    private Map<String, List<TripBean>> dayTrips = new HashMap<>();

    public TripBeanClusterHelper(List<TripBean> beanList) {
        this.beanList = beanList;

        TimeZone timeZone =  TimeZone.getDefault();

        dateFormat = new SimpleDateFormat("MMMM dd, yyyy", Locale.getDefault());
        dateFormat.setTimeZone(timeZone);
    }

    public List<List<TripBean>> getClusterList() {
        ArrayList<TripBean> tripBeans = new ArrayList<>(beanList);

        for (TripBean bean : tripBeans) {
            String drivingTime = bean.getDrivingTime();
            String[] arrTime = drivingTime.split("T");
            putTimeline(arrTime[1], bean);
        }

        return new ArrayList<>(dayTrips.values());
    }

    private void putTimeline(String date, TripBean bean) {
        List<TripBean> tripBeans = dayTrips.get(date);
        if (tripBeans == null) {
            tripBeans = new ArrayList<>();
        }
        tripBeans.add(bean);
        dayTrips.put(date, tripBeans);
    }
}
