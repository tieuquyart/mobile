package com.mk.autosecure.libs.utils;

import androidx.core.util.Pair;

import com.mkgroup.camera.model.Clip;
import com.mk.autosecure.model.ClipCluster;
import com.mk.autosecure.model.ClipSegment;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/*
 * Created by DoanVT on 2017/9/8.
 */

/**
 * Created by doanvt on 2022/11/02.
 */
public class ClipClusterHelper {

    private final static String TAG = ClipClusterHelper.class.getSimpleName();

    private List<Clip> mClipList;

    public ClipClusterHelper(List<Clip> clipList) {
        this.mClipList = clipList;
    }

    //包括不同clipSegment的ClipCluster集合
    public List<ClipCluster> getClipClusterList() {
        List<Clip> clipList = new ArrayList<>();
        clipList.addAll(mClipList);

        //逆向排序，时间最近的在前面
        Collections.sort(clipList, (lhs, rhs) -> {
            long diff = (rhs.getEndTimeMs() + rhs.getClipDateWithDST() - lhs.getEndTimeMs() - lhs.getClipDateWithDST());
            return diff > 0 ? 1 : -1;
        });

        List<ClipCluster> clipClusterList = new ArrayList<>();

        for (int i = 0; i < clipList.size(); ) {
            Clip clipStart = clipList.get(i);
            long startTime = clipStart.getStartTimeMs() + clipStart.getClipDateWithDST();
            long endTime = clipStart.getEndTimeMs() + clipStart.getClipDateWithDST();

            List<Clip> tempClipList = new ArrayList<>();
            tempClipList.add(clipStart);
            if (i == clipList.size() - 1) {
                i++;
            } else {
                for (int j = i + 1; j < clipList.size(); j++) {
                    Clip clip = clipList.get(j);
                    long curEndTime = clip.getEndTimeMs() + clip.getClipDateWithDST();
                    //区分是不是同一个clipSegment
                    if (startTime > curEndTime) {
                        i = j;
                        break;
                    } else {
                        tempClipList.add(clip);
                        startTime = Math.min(startTime, clip.getStartTimeMs() + clip.getClipDateWithDST());
                        if (j == clipList.size() - 1) {
                            i = j + 1;
                            break;
                        }
                    }
                }
            }
            List<Pair<Long, Boolean>> timePoints = new ArrayList<>();
            for (Clip clip : tempClipList) {
                timePoints.add(new Pair<>(clip.getStartTimeMs() + clip.getClipDateWithDST(), true));
                timePoints.add(new Pair<>(clip.getEndTimeMs() + clip.getClipDateWithDST(), false));
            }

            //逆向排序，时间最近的在前面
            Collections.sort(timePoints, (o1, o2) -> {
                if (o1.first != null && o2.first != null) {
                    return (int) (o2.first - o1.first);
                }
                return 0;
            });

            List<ClipSegment> tempSegList = new ArrayList<>();
            for (int index = 0; index < timePoints.size() - 1; index++) {
                Pair<Long, Boolean> endNode = timePoints.get(index);
                Pair<Long, Boolean> startNode = timePoints.get(index + 1);
                long end = endNode.first != null ? endNode.first : 0;
                long start = startNode.first != null ? startNode.first : 0;
                int clipType = -1;
                Clip topClip = null;
                for (Clip clip : tempClipList) {
                    if (clip.getStartTimeMs() + clip.getClipDateWithDST() <= start && clip.getEndTimeMs() + clip.getClipDateWithDST() >= end) {
                        if (clip.getVideoType() >= clipType) {
                            clipType = clip.getVideoType();
                            topClip = clip;
                        }
                    }
                }
                //默认不是开头
                boolean startSeg = endNode.second != null ? endNode.second : true;
                ClipSegment segment = new ClipSegment(start, end - start, clipType, topClip, !startSeg, false);
                tempSegList.add(segment);
            }

            ClipCluster clipCluster = new ClipCluster(tempClipList, startTime, endTime - startTime, tempSegList);
            clipClusterList.add(clipCluster);

        }
        return clipClusterList;

    }
}
