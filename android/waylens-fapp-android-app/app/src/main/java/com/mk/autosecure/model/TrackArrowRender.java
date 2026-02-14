package com.mk.autosecure.model;

import android.content.Context;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.clustering.Cluster;
import com.google.maps.android.clustering.ClusterManager;
import com.google.maps.android.clustering.view.DefaultClusterRenderer;

/**
 * Created by doanvt on 2022/11/02.
 */

public class TrackArrowRender extends DefaultClusterRenderer<TrackArrow> {

    private final static String TAG = TrackArrowRender.class.getSimpleName();

    public TrackArrowRender(Context context, GoogleMap map, ClusterManager<TrackArrow> clusterManager) {
        super(context, map, clusterManager);
    }

    @Override
    protected void onBeforeClusterItemRendered(TrackArrow item, MarkerOptions markerOptions) {
        markerOptions.anchor(0.5f, 0.5f)
                .rotation(item.rotation)
                .position(item.getPosition())
                .icon(BitmapDescriptorFactory.fromResource(item.resource));
    }

    @Override
    protected void onBeforeClusterRendered(Cluster<TrackArrow> cluster, MarkerOptions markerOptions) {
//        Logger.t(TAG).e("onBeforeClusterRendered: " + cluster.getSize());
        TrackArrow trackArrow = cluster.getItems().iterator().next();
        markerOptions.anchor(0.5f, 0.5f)
                .rotation(trackArrow.rotation)
                .position(trackArrow.getPosition())
                .icon(BitmapDescriptorFactory.fromResource(trackArrow.resource));
    }

    @Override
    protected boolean shouldRenderAsCluster(Cluster<TrackArrow> cluster) {
        return cluster.getSize() > 3;
    }
}
