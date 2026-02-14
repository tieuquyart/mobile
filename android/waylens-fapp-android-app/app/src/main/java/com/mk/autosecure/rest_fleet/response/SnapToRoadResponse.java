package com.mk.autosecure.rest_fleet.response;

import java.util.ArrayList;

public class SnapToRoadResponse {
    public ArrayList<SnappedPoint> snappedPoints;

    public class SnappedPoint{
        public Location location;
        public int originalIndex;
        public String placeId;
    }

    public class Location{
        public double latitude;
        public double longitude;
    }
}

