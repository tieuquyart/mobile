package com.mk.autosecure.libs.utils;

import com.mk.autosecure.ui.adapter.LocalVideoAdapter;
import com.mk.autosecure.model.ClipSegment;
import com.mk.autosecure.model.EventBeanCluster;
import com.mk.autosecure.model.EventBeanPos;
import com.mk.autosecure.rest_fleet.bean.EventBean;

/**
 * Created by doanvt on 2022/11/02.
 */
public class EventBeanUtils {

    public static EventBeanPos startOfNextSegment(EventBeanPos endPos, EventBeanCluster clipCluster) {
        if (endPos == null || clipCluster == null) {
            return null;
        }
        EventBean clip = endPos.getEventBean();
        long timeOffSet = clip.getStartTime() + endPos.getOffset();
        long curTime = timeOffSet;
        int index = -1;
        for (int i = 0; i < clipCluster.getClipSegment().size(); i++) {
            ClipSegment seg = clipCluster.getClipSegment().get(i);
            if (seg.startTime <= curTime + LocalVideoAdapter.playerTimeTolerance
                    && curTime - LocalVideoAdapter.playerTimeTolerance <= seg.startTime + seg.duration
                    && clip.equals(seg.data)) {
                index = i;
                break;
            }
        }
        if (index > 0 && index < clipCluster.getClipSegment().size()) {
            ClipSegment nextClipSegment = clipCluster.getClipSegment().get(index - 1);
            EventBean nextClip = (EventBean) nextClipSegment.data;
            return new EventBeanPos(nextClip, nextClipSegment.startTime - nextClip.getStartTime());
        }
        return null;
    }

}
