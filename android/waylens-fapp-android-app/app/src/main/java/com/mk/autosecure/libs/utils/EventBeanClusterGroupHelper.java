package com.mk.autosecure.libs.utils;

import com.mk.autosecure.model.EventBeanCluster;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Created by doanvt on 2022/11/02.
 */
public class EventBeanClusterGroupHelper {

    private final List<EventBeanCluster> eventClusters;

    private Map<String, List<EventBeanCluster>> mEventClusterGroup = new HashMap<>();

    public EventBeanClusterGroupHelper(List<EventBeanCluster> eventClusters) {
        this.eventClusters = eventClusters;
    }

    public List<List<EventBeanCluster>> getEventClusterGroup() {
        calculateEventClusterGroup(eventClusters);

        List<List<EventBeanCluster>> eventClusterGroup = new ArrayList<>();
        Iterator iter = mEventClusterGroup.entrySet().iterator();
        while (iter.hasNext()) {
            Map.Entry entry = (Map.Entry) iter.next();
            eventClusterGroup.add((List<EventBeanCluster>) entry.getValue());
        }
        Collections.sort(eventClusterGroup, (lhs, rhs) -> (int) (rhs.get(0).getStartTime() / 1000 - lhs.get(0).getStartTime() / 1000));
        return eventClusterGroup;
    }

    private void calculateEventClusterGroup(List<EventBeanCluster> eventClusterList) {
        for (EventBeanCluster eventCluster : eventClusterList) {

            String dateString = eventCluster.getDateString();
            List<EventBeanCluster> oneEventClusterList = mEventClusterGroup.get(dateString);
            if (oneEventClusterList == null) {
                oneEventClusterList = new ArrayList<>();
                mEventClusterGroup.put(dateString, oneEventClusterList);
            }
            oneEventClusterList.add(eventCluster);
        }
    }
}
