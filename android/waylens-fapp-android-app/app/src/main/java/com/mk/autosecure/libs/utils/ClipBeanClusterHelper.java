package com.mk.autosecure.libs.utils;

import androidx.core.util.Pair;

import com.mk.autosecure.constant.VideoEventType;
import com.mkgroup.camera.bean.ClipBean;
import com.mk.autosecure.model.ClipBeanCluster;
import com.mk.autosecure.model.ClipSegment;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by DoanVT on 2017/9/5.
 */

public class ClipBeanClusterHelper {

    private final static String TAG = ClipBeanClusterHelper.class.getSimpleName();

    private List<ClipBean> mClipBeanList;

    public ClipBeanClusterHelper(List<ClipBean> clipBeanList) {
        this.mClipBeanList = clipBeanList;
    }

    public List<ClipBeanCluster> getClipBeanClusterList() {
        List<ClipBean> clipBeanList = new ArrayList<>(mClipBeanList);

        Collections.sort(clipBeanList, (lhs, rhs) -> (int) (rhs.captureTime + rhs.durationMs - lhs.captureTime - lhs.durationMs));

        List<ClipBeanCluster> clipBeanClusterList = new ArrayList<>();

        for (int i = 0; i < clipBeanList.size(); i++) {
            ClipBean clipBeanStart = clipBeanList.get(i);
            long startTime = clipBeanStart.captureTime;
            long endTime = clipBeanStart.captureTime + clipBeanStart.durationMs;

            List<ClipBean> tempClipBeanList = new ArrayList<>();
            tempClipBeanList.add(clipBeanStart);

            List<Pair<Long, Boolean>> timePoints = new ArrayList<>();
            for (ClipBean clipBean : tempClipBeanList) {
                timePoints.add(new Pair<>(clipBean.captureTime, true));
                timePoints.add(new Pair<>(clipBean.captureTime + clipBean.durationMs, false));
            }

            Collections.sort(timePoints, (o1, o2) -> (int) (o2.first - o1.first));

            List<ClipSegment> tempSegList = new ArrayList<>();
            for (int index = 0; index < timePoints.size() - 1; index++) {
                Pair<Long, Boolean> endNode = timePoints.get(index);
                Pair<Long, Boolean> startNode = timePoints.get(index + 1);
                long end = endNode.first;
                long start = startNode.first;
                int clipType = -1;
                ClipBean topClipBean = null;
                for (ClipBean clipBean : tempClipBeanList) {
                    if (clipBean.captureTime <= start && clipBean.captureTime + clipBean.durationMs >= end) {
                        int typeForInteger = VideoEventType.getEventTypeForInteger(clipBean.clipType);
                        if (typeForInteger > clipType) {
                            clipType = typeForInteger;
                            topClipBean = clipBean;
                        }
                    }
                }
                ClipSegment segment = new ClipSegment(start, end - start, clipType, topClipBean, true, true);
                tempSegList.add(segment);
            }

            ClipBeanCluster clipBeanCluster = new ClipBeanCluster(tempClipBeanList, startTime, endTime - startTime, tempSegList);
            clipBeanClusterList.add(clipBeanCluster);

        }
        return clipBeanClusterList;

    }
}
