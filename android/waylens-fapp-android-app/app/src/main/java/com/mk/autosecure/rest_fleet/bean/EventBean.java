package com.mk.autosecure.rest_fleet.bean;

import java.io.Serializable;

public class EventBean implements Serializable {

    /**
     * momentID : 328454347144822784
     * clipID : 328454347144822784
     * cameraSN : 2B17NKND
     * vehicleID : 2fc87551fb08495d
     * eventType : HARD_BRAKE
     * startTime : 1567421203000
     * duration : 20000
     * hlsUrl : https://fleettestcdn.waylens.com/clip/268515b6e04e48e5838a3fcfed63d65c/2fc87551fb08495d/2B17NKND/328454347144822784/1952x1952/32.m3u8
     * mp4Url : https://fleettestcdn.waylens.com/clip/268515b6e04e48e5838a3fcfed63d65c/2fc87551fb08495d/2B17NKND/328454347144822784/1952x1952/32.mp4?
     * Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9mbGVldHRlc3RjZG4ud2F5bGVucy5jb20vY2xpcC8yNjg1MTViNmUwNGU0OGU1ODM4YTNmY2ZlZDYzZDY1Yy8yZmM4NzU1MWZiMDg0OTVkLzJCMTdOS05ELzMyODQ1NDM0NzE0NDgyMjc4NC8xOTUyeDE5NTIvMzIubXA0IiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTY3NDg0NTI2fX19XX0_
     * &Signature=Ghzvt5R0sWCGaL4x9ycU3JzKz29B3qZTIUpmIUFDGMztZ2xKYy~LV4fPJ-FOPbk3qGCOIOZFsktI5KTIm8HaLMG-qQDqgbQp3xXPpjynymECxxlkRQsd17Chz8lHDIQxZ~WRTHUmZ3kygTeZyj-0C5JCKrD6fNojUIglm1UtHhv-OKRJQdY89wdsAkOYvca8D8xC6QWdFHKjjRN8yD1qx2Lr-NQM4tbC88--yx8WnLZsv~nsaqDb0nGYY5MDdfQHsKGb9RdJscbq1WZ~3vEzlkW6J8pBcrVD52FcbES5uHks3FiUXdffLN1-A~FimSkI7TgEc1xC60Xsrkc2WMz~SQ__
     * &Key-Pair-Id=APKAIZCLN7KQEMMEJXJQ
     * rotate : normal
     */

    private long momentID;
    private long clipID;
    private String cameraSN;
    private String vehicleID;
    private String eventType;
    private long startTime;
    private int duration;
    private String hlsUrl;
    private String mp4Url;
    private String rotate;

    public long getMomentID() {
        return momentID;
    }

    public void setMomentID(long momentID) {
        this.momentID = momentID;
    }

    public long getClipID() {
        return clipID;
    }

    public void setClipID(long clipID) {
        this.clipID = clipID;
    }

    public String getCameraSN() {
        return cameraSN;
    }

    public void setCameraSN(String cameraSN) {
        this.cameraSN = cameraSN;
    }

    public String getVehicleID() {
        return vehicleID;
    }

    public void setVehicleID(String vehicleID) {
        this.vehicleID = vehicleID;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public long getStartTime() {
        return startTime;
    }

    public void setStartTime(long startTime) {
        this.startTime = startTime;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public String getHlsUrl() {
        return hlsUrl;
    }

    public void setHlsUrl(String hlsUrl) {
        this.hlsUrl = hlsUrl;
    }

    public String getMp4Url() {
        return mp4Url;
    }

    public void setMp4Url(String mp4Url) {
        this.mp4Url = mp4Url;
    }

    public String getRotate() {
        return rotate;
    }

    public void setRotate(String rotate) {
        this.rotate = rotate;
    }

    @Override
    public String toString() {
        return "EventBean{" +
                "momentID=" + momentID +
                ", clipID=" + clipID +
                ", cameraSN='" + cameraSN + '\'' +
                ", vehicleID='" + vehicleID + '\'' +
                ", eventType='" + eventType + '\'' +
                ", startTime=" + startTime +
                ", duration=" + duration +
                ", hlsUrl='" + hlsUrl + '\'' +
                ", mp4Url='" + mp4Url + '\'' +
                ", rotate='" + rotate + '\'' +
                '}';
    }
}
