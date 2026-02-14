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
public class ClusterMarkerRender extends DefaultClusterRenderer<ClusterMarker> {

    private final static String TAG = ClusterMarkerRender.class.getSimpleName();

    public ClusterMarkerRender(Context context, GoogleMap map, ClusterManager<ClusterMarker> clusterManager) {
        super(context, map, clusterManager);
    }

    @Override
    protected void onBeforeClusterItemRendered(ClusterMarker item, MarkerOptions markerOptions) {
        markerOptions.anchor(0.5f, 0.5f)
                .zIndex(item.getzIndex())
                .position(item.getPosition())
                .icon(BitmapDescriptorFactory.fromResource(item.getResource()));
    }

    @Override
    protected void onBeforeClusterRendered(Cluster<ClusterMarker> cluster, MarkerOptions markerOptions) {
//        Logger.t(TAG).e("onBeforeClusterRendered: " + cluster.getSize());
        ClusterMarker clusterMarker = cluster.getItems().iterator().next();
        markerOptions.anchor(0.5f, 0.5f)
                .zIndex(clusterMarker.getzIndex())
                .position(clusterMarker.getPosition())
                .icon(BitmapDescriptorFactory.fromResource(clusterMarker.getResource()));
    }

    @Override
    protected boolean shouldRenderAsCluster(Cluster<ClusterMarker> cluster) {
        return cluster.getSize() > 1;
    }
}
