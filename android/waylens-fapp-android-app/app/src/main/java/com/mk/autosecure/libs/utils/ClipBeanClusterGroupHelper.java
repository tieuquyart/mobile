package com.mk.autosecure.libs.utils;

import com.mk.autosecure.model.ClipBeanCluster;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Created by DoanVT on 2017/11/28.
 * Email: doanvt-hn@mk.com.vn
 */

public class ClipBeanClusterGroupHelper {
    private final List<ClipBeanCluster> clipClusters;

    private Map<String, List<ClipBeanCluster>> mClipClusterGroup = new HashMap<>();

    public ClipBeanClusterGroupHelper(List<ClipBeanCluster> clipClusters) {
        this.clipClusters = clipClusters;
    }

    public List<List<ClipBeanCluster>> getClipClusterGroup() {
        calculateClipClusterGroup(clipClusters);

        List<List<ClipBeanCluster>> clipClusterGroup = new ArrayList<>();
        Iterator iter = mClipClusterGroup.entrySet().iterator();
        while (iter.hasNext()) {
            Map.Entry entry = (Map.Entry) iter.next();
            clipClusterGroup.add((List<ClipBeanCluster>) entry.getValue());
        }
        Collections.sort(clipClusterGroup, new Comparator<List<ClipBeanCluster>>() {
            @Override
            public int compare(List<ClipBeanCluster> lhs, List<ClipBeanCluster> rhs) {
                return (int) (rhs.get(0).getStartTime() / 1000 - lhs.get(0).getStartTime() / 1000);
            }
        });
        return clipClusterGroup;
    }

    private void calculateClipClusterGroup(List<ClipBeanCluster> clipClusterList) {
        for (ClipBeanCluster clipCluster : clipClusterList) {

            String clipDataString = clipCluster.getDateString();
            List<ClipBeanCluster> oneClipClusterList = mClipClusterGroup.get(clipDataString);
            if (oneClipClusterList == null) {
//                com.orhanobut.logger.Logger.t("test").e("clipDataString: "+clipDataString);
                oneClipClusterList = new ArrayList<>();
                mClipClusterGroup.put(clipDataString, oneClipClusterList);
            }
            oneClipClusterList.add(clipCluster);
        }
    }
}
