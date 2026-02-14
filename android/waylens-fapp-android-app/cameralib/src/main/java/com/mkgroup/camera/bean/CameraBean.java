package com.mkgroup.camera.bean;


import java.io.Serializable;
import java.util.Objects;

/**
 * Created by DoanVT on 2017/8/9.
 * Email: doanvt-hn@mk.com.vn
 */
public class CameraBean implements Serializable {
    public String sn;
    public Boolean is4G;
    public String currRatePlan;
    public String name;
    public Boolean isOnline;
    public Long onlineStatusChangeTime;

    public ClipBean.GPS gps;

    public Location location;

    public String thumbnailUrl;
    public Long thumbnailTime;
    public String hardwareModel;
    public String hardwareVersion;

    public SettingReportBody.Setting settings;

    public CameraState state;

    public FourGSignalResponse _4gSignal;

    public String rotate; // 旧版本，相机没有上报成功时该字段为空

    @Override
    public String toString() {
        return "CameraBean{" +
                "sn='" + sn + '\'' +
                ", is4G=" + is4G +
                ", currRatePlan='" + currRatePlan + '\'' +
                ", name='" + name + '\'' +
                ", isOnline=" + isOnline +
                ", onlineStatusChangeTime=" + onlineStatusChangeTime +
                ", gps=" + gps +
                ", location=" + location +
                ", thumbnailUrl='" + thumbnailUrl + '\'' +
                ", thumbnailTime=" + thumbnailTime +
                ", hardwareModel='" + hardwareModel + '\'' +
                ", hardwareVersion='" + hardwareVersion + '\'' +
                ", settings=" + settings +
                ", state=" + state +
                ", _4gSignal=" + _4gSignal +
                ", rotate='" + rotate + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        CameraBean that = (CameraBean) o;
        return Objects.equals(sn, that.sn) &&
                Objects.equals(is4G, that.is4G) &&
                Objects.equals(currRatePlan, that.currRatePlan) &&
                Objects.equals(name, that.name) &&
                Objects.equals(isOnline, that.isOnline) &&
                Objects.equals(onlineStatusChangeTime, that.onlineStatusChangeTime) &&
                Objects.equals(gps, that.gps) &&
                Objects.equals(location, that.location) &&
                Objects.equals(thumbnailUrl, that.thumbnailUrl) &&
                Objects.equals(thumbnailTime, that.thumbnailTime) &&
                Objects.equals(hardwareModel, that.hardwareModel) &&
                Objects.equals(hardwareVersion, that.hardwareVersion) &&
                Objects.equals(settings, that.settings) &&
                Objects.equals(state, that.state) &&
                Objects.equals(_4gSignal, that._4gSignal) &&
                Objects.equals(rotate, that.rotate);
    }

    @Override
    public int hashCode() {
        return Objects.hash(sn, is4G, currRatePlan, name, isOnline, onlineStatusChangeTime, gps, location, thumbnailUrl, thumbnailTime, hardwareModel, hardwareVersion, settings, state, _4gSignal, rotate);
    }

    public static class Location implements Serializable {
        public String country;
        public String region;
        public String city;
        public String route;//街道信息
        public String streetNumber;//门牌信息
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

}
