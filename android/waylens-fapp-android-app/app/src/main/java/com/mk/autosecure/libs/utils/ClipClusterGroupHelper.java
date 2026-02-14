package com.mk.autosecure.libs.utils;

import com.mk.autosecure.model.ClipCluster;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by DoanVT on 2017/11/28.
 * Email: doanvt-hn@mk.com.vn
 */

public class ClipClusterGroupHelper {

    private final List<ClipCluster> clipClusters;

    private Map<String, List<ClipCluster>> mClipClusterGroup = new HashMap<>();

    public ClipClusterGroupHelper(List<ClipCluster> clipClusters) {
        this.clipClusters = clipClusters;
    }

    //不同日期的ClipCluster集合
    public List<List<ClipCluster>> getClipClusterGroup() {
        calculateClipClusterGroup(clipClusters);

        List<List<ClipCluster>> clipClusterGroup = new ArrayList<>();
        clipClusterGroup.addAll(mClipClusterGroup.values());

        //逆向排序
        Collections.sort(clipClusterGroup, (lhs, rhs) ->
                (int) (rhs.get(0).getStartTime() / 1000 - lhs.get(0).getStartTime() / 1000));

        return clipClusterGroup;
    }

    //按日期筛选
    private void calculateClipClusterGroup(List<ClipCluster> clipClusterList) {
        for (ClipCluster clipCluster : clipClusterList) {
            String clipDataString = clipCluster.getDateString();
            List<ClipCluster> oneClipClusterList = mClipClusterGroup.get(clipDataString);
            if (oneClipClusterList == null) {
                oneClipClusterList = new ArrayList<>();
                mClipClusterGroup.put(clipDataString, oneClipClusterList);
            }
            oneClipClusterList.add(clipCluster);
        }
    }
}
