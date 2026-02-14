package com.mk.autosecure.rest_fleet.bean;

public class EventDetailBean {

    /**
     * plateNumber : 2B17NKND
     * driver : waylensDriver6
     * clipID : 337434203043921920
     * cameraSN : 2B17NKND
     * eventType : HARD_BRAKE
     * startTime : 1569562168000
     * rotate : upsidedown
     * coordinate : {"longitude":0,"latitude":0,"altitude":0}
     * url : https://fleettestcdn.waylens.com/clip/268515b6e04e48e5838a3fcfed63d65c/2fc87551fb08495d/2B17NKND/337434203043921920/1952x1952/32.mp4?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9mbGVldHRlc3RjZG4ud2F5bGVucy5jb20vY2xpcC8yNjg1MTViNmUwNGU0OGU1ODM4YTNmY2ZlZDYzZDY1Yy8yZmM4NzU1MWZiMDg0OTVkLzJCMTdOS05ELzMzNzQzNDIwMzA0MzkyMTkyMC8xOTUyeDE5NTIvMzIubXA0IiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTY5NzMwNDY0fX19XX0_&Signature=M2GOt0yNbGguxFN7LfqZbbC2TwB-054UQJWlWqZiIzyyTsfsUBueTy3XLYUH07FlfEEKVHozWMjs9Pi~asbeyQE1pOgtZkrc86pqOMSfUIaF6S-fpLLzgs12TzW48Kf64NNwzqN4~1xBdfWgWNQNX-SETz2RKNo-EjQlQ3Sp~jzWcW3dcYCrZXKTP8t9L0uEj-WRgLdVlF5SBBaB5BWuUbCGOfCzc~yFtc8aHGM3xtVoj6ZBpo2Ae70v4X50OodQc3-zlC3d8LtvI-f6AzAmD9lMj2CNn5SvV4GHu1h1WjJXcLTqqHvoblUOaMjhkXCAZiYN3tUZiNPEsW4mTOCd2Q__&Key-Pair-Id=APKAIZCLN7KQEMMEJXJQ
     */

    private String plateNumber;
    private String driver;
    private String clipID;
    private String cameraSN;
    private String eventType;
    private long startTime;
    private int duration;
    private String rotate;
    private String url;

    /**
     * coordinate : {"longitude":121.601505,"latitude":31.1908297,"altitude":15.5}
     */

    private CoordinateBean coordinate;

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public String getDriver() {
        return driver;
    }

    public void setDriver(String driver) {
        this.driver = driver;
    }

    public String getClipID() {
        return clipID;
    }

    public void setClipID(String clipID) {
        this.clipID = clipID;
    }

    public String getCameraSN() {
        return cameraSN;
    }

    public void setCameraSN(String cameraSN) {
        this.cameraSN = cameraSN;
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

    public String getRotate() {
        return rotate;
    }

    public void setRotate(String rotate) {
        this.rotate = rotate;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    @Override
    public String toString() {
        return "EventDetailBean{" +
                "plateNumber='" + plateNumber + '\'' +
                ", driver='" + driver + '\'' +
                ", clipID='" + clipID + '\'' +
                ", cameraSN='" + cameraSN + '\'' +
                ", eventType='" + eventType + '\'' +
                ", startTime=" + startTime +
                ", duration=" + duration +
                ", rotate='" + rotate + '\'' +
                ", coordinate=" + coordinate +
                ", url='" + url + '\'' +
                '}';
    }

    public CoordinateBean getCoordinate() {
        return coordinate;
    }

    public void setCoordinate(CoordinateBean coordinate) {
        this.coordinate = coordinate;
    }

    public static class CoordinateBean {
        /**
         * longitude : 121.601505
         * latitude : 31.1908297
         * altitude : 15.5
         */

        private double longitude;
        private double latitude;
        private double altitude;

        public double getLongitude() {
            return longitude;
        }

        public void setLongitude(double longitude) {
            this.longitude = longitude;
        }

        public double getLatitude() {
            return latitude;
        }

        public void setLatitude(double latitude) {
            this.latitude = latitude;
        }

        public double getAltitude() {
            return altitude;
        }

        public void setAltitude(double altitude) {
            this.altitude = altitude;
        }

        @Override
        public String toString() {
            return "CoordinateBean{" +
                    "longitude=" + longitude +
                    ", latitude=" + latitude +
                    ", altitude=" + altitude +
                    '}';
        }
    }
}
