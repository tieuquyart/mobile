package com.mkgroup.camera.bean;

import java.io.Serializable;
import java.util.Objects;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class Alert implements Serializable {
    public static final String TYPE_VIDEO = "VIDEO";
    public static final String TYPE_PICTURE = "PICTURE";

    public Long eventID;
    public String cameraName;
    public String sn;

    public GPS gps;

    public Location location;

    public String status;
    public Long alertTime;
    public Long mediaFileID;
    public String url;
    public String alertType;
    public String mediaType;  //"video" or "picture"
    public String thumbnail;
    public Long durationMs;
    public String rotate;
    public Boolean isRead;

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
    }

    @Override
    public String toString() {
        return "Alert{" +
                "eventID=" + eventID +
                ", cameraName='" + cameraName + '\'' +
                ", sn='" + sn + '\'' +
                ", gps=" + gps +
                ", location=" + location +
                ", status='" + status + '\'' +
                ", alertTime=" + alertTime +
                ", mediaFileID=" + mediaFileID +
                ", url='" + url + '\'' +
                ", alertType='" + alertType + '\'' +
                ", mediaType='" + mediaType + '\'' +
                ", thumbnail='" + thumbnail + '\'' +
                ", durationMs=" + durationMs +
                ", rotate='" + rotate + '\'' +
                ", isRead=" + isRead +
                '}';
    }
}
