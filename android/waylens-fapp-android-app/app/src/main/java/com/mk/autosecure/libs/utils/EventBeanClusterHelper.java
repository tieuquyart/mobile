package com.mk.autosecure.libs.utils;

import androidx.core.util.Pair;

import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.model.ClipSegment;
import com.mk.autosecure.model.EventBeanCluster;
import com.mk.autosecure.rest_fleet.bean.EventBean;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by doanvt on 2022/11/02.
 */
public class EventBeanClusterHelper {

    private final static String TAG = EventBeanClusterHelper.class.getSimpleName();

    private List<EventBean> mEventBeanList;

    public EventBeanClusterHelper(List<EventBean> beanList) {
        this.mEventBeanList = beanList;
    }

    public List<EventBeanCluster> getEventBeanClusterList() {
        List<EventBean> eventBeanList = new ArrayList<>(mEventBeanList);

        Collections.sort(eventBeanList, (lhs, rhs) -> (int) (rhs.getStartTime() + rhs.getDuration() - lhs.getStartTime() - lhs.getDuration()));

        List<EventBeanCluster> eventBeanClusterList = new ArrayList<>();

        for (int i = 0; i < eventBeanList.size(); i++) {
            EventBean eventBeanStart = eventBeanList.get(i);
            long startTime = eventBeanStart.getStartTime();
            long endTime = eventBeanStart.getStartTime() + eventBeanStart.getDuration();

            List<EventBean> tempEventBeanList = new ArrayList<>();
            tempEventBeanList.add(eventBeanStart);

            List<Pair<Long, Boolean>> timePoints = new ArrayList<>();
            for (EventBean bean : tempEventBeanList) {
                timePoints.add(new Pair<>(bean.getStartTime(), true));
                timePoints.add(new Pair<>(bean.getStartTime() + bean.getDuration(), false));
            }

            Collections.sort(timePoints, (o1, o2) -> (int) (o2.first - o1.first));

            List<ClipSegment> tempSegList = new ArrayList<>();
            for (int index = 0; index < timePoints.size() - 1; index++) {
                Pair<Long, Boolean> endNode = timePoints.get(index);
                Pair<Long, Boolean> startNode = timePoints.get(index + 1);
                long end = endNode.first;
                long start = startNode.first;
                int clipType = -1;
                EventBean topEventBean = null;
                for (EventBean eventBean : tempEventBeanList) {
                    if (eventBean.getStartTime() <= start && eventBean.getStartTime() + eventBean.getDuration() >= end) {
                        int typeForInteger = VideoEventType.getEventTypeForInteger(eventBean.getEventType());
                        if (typeForInteger > clipType) {
                            clipType = typeForInteger;
                            topEventBean = eventBean;
                        }
                    }
                }
                ClipSegment segment = new ClipSegment(start, end - start, clipType, topEventBean, true, true);
                tempSegList.add(segment);
            }

            EventBeanCluster eventBeanCluster = new EventBeanCluster(tempEventBeanList, startTime, endTime - startTime, tempSegList);
            eventBeanClusterList.add(eventBeanCluster);

        }
        return eventBeanClusterList;

    }

}
