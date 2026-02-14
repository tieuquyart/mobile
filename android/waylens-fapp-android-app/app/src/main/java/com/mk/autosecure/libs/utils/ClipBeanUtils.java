package com.mk.autosecure.libs.utils;

import com.mk.autosecure.ui.adapter.LocalVideoAdapter;
import com.mkgroup.camera.bean.ClipBean;
import com.mk.autosecure.model.ClipBeanCluster;
import com.mk.autosecure.model.ClipBeanPos;
import com.mk.autosecure.model.ClipSegment;

/**
 * Created by doanvt on 2022/11/02.
 */
public class ClipBeanUtils {

    public static ClipBeanPos startOfNextSegment(ClipBeanPos endPos, ClipBeanCluster clipCluster) {
        if (endPos == null || clipCluster == null) {
            return null;
        }
        ClipBean clip = endPos.getClipBean();
        long timeOffSet = clip.getStartTimeMs() + endPos.getOffset();
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
            ClipBean nextClip = (ClipBean) nextClipSegment.data;
            return new ClipBeanPos(nextClip, nextClipSegment.startTime - nextClip.getStartTimeMs());
        }
        return null;
    }

}
