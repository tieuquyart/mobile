package com.mk.autosecure.rest_fleet;

import com.google.android.gms.maps.model.LatLng;

import java.util.List;

public interface SnapToRoadCallback {
    void onCallBack(List<LatLng> latLngs);
}
