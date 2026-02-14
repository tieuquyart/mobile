package com.mk.autosecure.model;

import com.google.android.gms.maps.model.LatLng;
import com.google.maps.android.clustering.ClusterItem;

/**
 * Created by doanvt on 2022/11/02.
 */
public class TrackArrow implements ClusterItem {

    private final LatLng mPosition;
    public final int resource;
    public final float rotation;

    public TrackArrow(LatLng mPosition, int resource, float rotation) {
        this.mPosition = mPosition;
        this.resource = resource;
        this.rotation = rotation;
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
        return null;
    }
}
