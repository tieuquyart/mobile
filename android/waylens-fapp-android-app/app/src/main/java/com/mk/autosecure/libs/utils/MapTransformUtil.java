package com.mk.autosecure.libs.utils;

import android.location.Location;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;

public class MapTransformUtil {

    private static final double ECa = 6378245.0;
    private static final double ECee = 0.00669342162296594323;
    private static final double pi = 3.14159265358979324;

    /**
     * 原始坐标系转火星坐标系
     */
    public static LatLng gps84_To_Gcj02(LatLng latLng) {
        if (latLng == null) {
            return null;
        }

        double lat = latLng.latitude;
        double lng = latLng.longitude;

        if (outOfChina(lat, lng)) {
            return latLng;
        }

        double x = lng - 105.0;
        double y = lat - 35.0;

        double dLat = transformLat(x, y);
        double dLng = transformLng(x, y);

        double radLat = lat / 180.0 * pi;
        double magic = Math.sin(radLat);
        magic = 1 - ECee * magic * magic;
        double sqrtMagic = Math.sqrt(magic);
        dLat = (dLat * 180.0) / ((ECa * (1 - ECee)) / (magic * sqrtMagic) * pi);
        dLng = (dLng * 180.0) / (ECa / sqrtMagic * Math.cos(radLat) * pi);

        return new LatLng(lat + dLat, lng + dLng);
    }

    /**
     * 火星坐标系转原始坐标系
     */
    public static LatLng gcj02_To_Gps84(LatLng latLng) {
        if (latLng == null) {
            return null;
        }
        double latitude = latLng.latitude;
        double longitude = latLng.longitude;
        double[] gps = gps84_To_Gcj02(latitude, longitude);
        return new LatLng(latitude * 2 - gps[0], longitude * 2 - gps[1]);
    }

    private static boolean outOfChina(double lat, double lng) {
        if (lng < 73.3 || lng > 135.17)
            return true;
        if (lat < 3.5 || lat > 53.6)
            return true;
        if (lat < 39.8 && lat > 124.3)// Korea & Japan
            return true;
        if (lat < 25.4 && lat > 120.3)// Taiwan
            return true;
        if (lat < 24 && lat > 119)// Taiwan
            return true;
        if (lat < 21 && lat < 108.1)// SouthEastAsia
            return true;
        if (lng < 108 && (lng + lat < 107))
            return true;
        if (lng < 97 && lat < 26.8) //india
            return true;
        if (lng < 107 && lat > 10) //india
            return true;
        return lat < 26.8 && lat < 97;
    }

    private static double transformLat(double x, double y) {
        double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * Math.sqrt(Math.abs(x));
        ret += (20.0 * Math.sin(6.0 * x * pi) + 20.0 * Math.sin(2.0 * x * pi)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(y * pi) + 40.0 * Math.sin(y / 3.0 * pi)) * 2.0 / 3.0;
        ret += (160.0 * Math.sin(y / 12.0 * pi) + 320 * Math.sin(y * pi / 30.0)) * 2.0 / 3.0;
        return ret;
    }

    private static double transformLng(double x, double y) {
        double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * Math.sqrt(Math.abs(x));
        ret += (20.0 * Math.sin(6.0 * x * pi) + 20.0 * Math.sin(2.0 * x * pi)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(x * pi) + 40.0 * Math.sin(x / 3.0 * pi)) * 2.0 / 3.0;
        ret += (150.0 * Math.sin(x / 12.0 * pi) + 300.0 * Math.sin(x / 30.0 * pi)) * 2.0 / 3.0;
        return ret;
    }

    private static double[] gps84_To_Gcj02(double lat, double lng) {
        if (outOfChina(lat, lng)) {
            return new double[]{lat, lng};
        }
        double dLat = transformLat(lng - 105.0, lat - 35.0);
        double dLng = transformLng(lng - 105, lat - 35.0);
        double radLat = lat / 180.0 * pi;
        double magic = Math.sin(radLat);
        magic = 1 - ECee * magic * magic;
        double sqrtMagic = Math.sqrt(magic);
        dLat = (dLat * 180.0) / ((ECa * (1 - ECee)) / (magic * sqrtMagic) * pi);
        dLng = (dLng * 180.0) / (ECa / sqrtMagic * Math.cos(radLat) * pi);
        double mgLat = lat + dLat;
        double mgLng = lng + dLng;
        return new double[]{mgLat, mgLng};
    }

    /**
     * 根据地理围栏半径计算当前地图自适应的缩放比例
     */
    public static float getZoomLevel(GoogleMap googleMap, int radius) {
        float zoomLevel = googleMap.getCameraPosition().zoom;

        LatLngBounds bounds = googleMap.getProjection().getVisibleRegion().latLngBounds;
        double llNeLat = bounds.northeast.latitude;
        double llSwLat = bounds.southwest.latitude;
        double llNeLng = bounds.northeast.longitude;
        double llSwLng = bounds.southwest.longitude;
        float[] results = new float[1];
        Location.distanceBetween(llNeLat, llNeLng, llSwLat, llSwLng, results);

        float mapRadius = results[0] / 2 / 5 * 3; // 暂时以3，4，5三角形计算半径
        double v = Math.log(mapRadius / radius) / Math.log(2);
        return (int) (zoomLevel + v);
    }
}
