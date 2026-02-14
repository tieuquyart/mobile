package com.mk.autosecure.model;

import com.google.android.gms.maps.model.LatLng;
import com.google.maps.android.clustering.ClusterItem;

/**
 * Created by doanvt on 2022/11/02.
 */
public class ClusterMarker implements ClusterItem {

    private int resource;
    private float zIndex;
    private String snippet;
    private LatLng mPosition;

    public ClusterMarker() {
    }

    public void setPosition(LatLng mPosition) {
        this.mPosition = mPosition;
    }

    public void setResource(int resource) {
        this.resource = resource;
    }

    public int getResource() {
        return resource;
    }

    public float getzIndex() {
        return zIndex;
    }

    @Override
    public LatLng getPosition() {
        return mPosition;
    }

    @Override
    public String getTitle() {
        return null;
    }

    @Override
    public String getSnippet() {
        return snippet;
    }
}
