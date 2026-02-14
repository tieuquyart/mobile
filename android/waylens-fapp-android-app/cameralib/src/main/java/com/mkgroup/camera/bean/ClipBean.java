package com.mkgroup.camera.bean;

import java.io.Serializable;
import java.util.Objects;

/**
 * Created by DoanVT on 2017/8/31.
 */

public class ClipBean implements Serializable {

    public Long clipID;
    public GPS gps;
    public Location location;

    public Long captureTime;
    public Integer captureTimeZone;

    public String rotate;

    public String url;
    public String clipType;// DRIVING_HIT, DRIVING_HEAVY_HIT, PARKING_MOTION, PARKING_HIT, PARKING_HEAVY_HIT, STREAMING, HIGHLIGHT

    public String mediaType;// video, picture
    public String thumbnail;
    public long durationMs;

    public static class GPS implements Serializable {
        public Double latitude;
        public Double longitude;
        public Double altitude;

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            GPS gps = (GPS) o;
            return Objects.equals(latitude, gps.latitude) &&
                    Objects.equals(longitude, gps.longitude) &&
                    Objects.equals(altitude, gps.altitude);
        }

        @Override
        public int hashCode() {
            return Objects.hash(latitude, longitude, altitude);
        }

        @Override
        public String toString() {
            return "GPS{" +
                    "latitude=" + latitude +
                    ", longitude=" + longitude +
                    ", altitude=" + altitude +
                    '}';
        }
    }

    public static class Location implements Serializable {
        public String country;
        public String region;
        public String city;
        public String route;
        public String streetNumber;
        public String address;

        @Override
        public String toString() {
            return "Location{" +
                    "country='" + country + '\'' +
                    ", region='" + region + '\'' +
                    ", city='" + city + '\'' +
                    ", route='" + route + '\'' +
                    ", streetNumber='" + streetNumber + '\'' +
                    ", address='" + address + '\'' +
                    '}';
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            Location location = (Location) o;
            return Objects.equals(country, location.country) &&
                    Objects.equals(region, location.region) &&
                    Objects.equals(city, location.city) &&
                    Objects.equals(route, location.route) &&
                    Objects.equals(streetNumber, location.streetNumber) &&
                    Objects.equals(address, location.address);
        }

        @Override
        public int hashCode() {
            return Objects.hash(country, region, city, route, streetNumber, address);
        }
    }

    public long getStartTimeMs() {
        return captureTime;
    }

    public long getDuration() {
        return durationMs;
    }

    @Override
    public String toString() {
        return "ClipBean{" +
                "clipID=" + clipID +
                ", gps=" + gps +
                ", location=" + location +
                ", captureTime=" + captureTime +
                ", captureTimeZone=" + captureTimeZone +
                ", rotate='" + rotate + '\'' +
                ", url='" + url + '\'' +
                ", clipType='" + clipType + '\'' +
                ", mediaType='" + mediaType + '\'' +
                ", thumbnail='" + thumbnail + '\'' +
                ", durationMs=" + durationMs +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ClipBean clipBean = (ClipBean) o;
        return Objects.equals(clipID, clipBean.clipID) &&
                Objects.equals(gps, clipBean.gps) &&
                Objects.equals(location, clipBean.location) &&
                Objects.equals(captureTime, clipBean.captureTime) &&
                Objects.equals(captureTimeZone, clipBean.captureTimeZone) &&
                Objects.equals(rotate, clipBean.rotate) &&
                Objects.equals(url, clipBean.url) &&
                Objects.equals(clipType, clipBean.clipType) &&
                Objects.equals(mediaType, clipBean.mediaType) &&
                Objects.equals(thumbnail, clipBean.thumbnail) &&
                Objects.equals(durationMs, clipBean.durationMs);
    }

    @Override
    public int hashCode() {
        return Objects.hash(clipID, gps, location, captureTime, captureTimeZone, rotate, url, clipType, mediaType, thumbnail, durationMs);
    }
}
