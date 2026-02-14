package com.mkgroup.camera.bean;

import java.io.Serializable;
import java.util.List;
import java.util.Objects;

public class OnlineStatusResponse implements Serializable {

    /**
     * simState : UNKNOWN
     * isOnline : true
     * lastConnectTime : 1567075112058
     * lastDisconnectTime : 1567075101039
     * mode : driving
     * RSRP : -104.69999694824219
     * Band : LTE B5
     * DLEarfcn : 2452
     * lastGps : {"time":1567131425000,"speed":0.14630800485610962,"coordinate":[121.601548,31.1908913,14.2]}
     */

    private String simState;
    private boolean isOnline;
    private long lastConnectTime;
    private long lastDisconnectTime;
    private String mode;
    private double RSRP;
    private String Band;
    private int DLEarfcn;
    private LastGpsBean lastGps;

    public String getSimState() {
        return simState;
    }

    public void setSimState(String simState) {
        this.simState = simState;
    }

    public boolean isIsOnline() {
        return isOnline;
    }

    public void setIsOnline(boolean isOnline) {
        this.isOnline = isOnline;
    }

    public long getLastConnectTime() {
        return lastConnectTime;
    }

    public void setLastConnectTime(long lastConnectTime) {
        this.lastConnectTime = lastConnectTime;
    }

    public long getLastDisconnectTime() {
        return lastDisconnectTime;
    }

    public void setLastDisconnectTime(long lastDisconnectTime) {
        this.lastDisconnectTime = lastDisconnectTime;
    }

    public String getMode() {
        return mode;
    }

    public void setMode(String mode) {
        this.mode = mode;
    }

    public double getRSRP() {
        return RSRP;
    }

    public void setRSRP(double RSRP) {
        this.RSRP = RSRP;
    }

    public String getBand() {
        return Band;
    }

    public void setBand(String Band) {
        this.Band = Band;
    }

    public int getDLEarfcn() {
        return DLEarfcn;
    }

    public void setDLEarfcn(int DLEarfcn) {
        this.DLEarfcn = DLEarfcn;
    }

    public LastGpsBean getLastGps() {
        return lastGps;
    }

    public void setLastGps(LastGpsBean lastGps) {
        this.lastGps = lastGps;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        OnlineStatusResponse that = (OnlineStatusResponse) o;
        return isOnline == that.isOnline &&
                lastConnectTime == that.lastConnectTime &&
                lastDisconnectTime == that.lastDisconnectTime &&
                Double.compare(that.RSRP, RSRP) == 0 &&
                DLEarfcn == that.DLEarfcn &&
                Objects.equals(simState, that.simState) &&
                Objects.equals(mode, that.mode) &&
                Objects.equals(Band, that.Band) &&
                Objects.equals(lastGps, that.lastGps);
    }

    @Override
    public int hashCode() {
        return Objects.hash(simState, isOnline, lastConnectTime, lastDisconnectTime, mode, RSRP, Band, DLEarfcn, lastGps);
    }

    @Override
    public String toString() {
        return "OnlineStatusResponse{" +
                "simState='" + simState + '\'' +
                ", isOnline=" + isOnline +
                ", lastConnectTime=" + lastConnectTime +
                ", lastDisconnectTime=" + lastDisconnectTime +
                ", mode='" + mode + '\'' +
                ", RSRP=" + RSRP +
                ", Band='" + Band + '\'' +
                ", DLEarfcn=" + DLEarfcn +
                ", lastGps=" + lastGps +
                '}';
    }

    public static class LastGpsBean implements Serializable {
        /**
         * time : 1567131425000
         * speed : 0.14630800485610962
         * coordinate : [121.601548,31.1908913,14.2]
         */

        private long time;
        private double speed;
        private List<Double> coordinate;

        public long getTime() {
            return time;
        }

        public void setTime(long time) {
            this.time = time;
        }

        public double getSpeed() {
            return speed;
        }

        public void setSpeed(double speed) {
            this.speed = speed;
        }

        public List<Double> getCoordinate() {
            return coordinate;
        }

        public void setCoordinate(List<Double> coordinate) {
            this.coordinate = coordinate;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            LastGpsBean that = (LastGpsBean) o;
            return time == that.time &&
                    Double.compare(that.speed, speed) == 0 &&
                    Objects.equals(coordinate, that.coordinate);
        }

        @Override
        public int hashCode() {
            return Objects.hash(time, speed, coordinate);
        }

        @Override
        public String toString() {
            return "LastGpsBean{" +
                    "time=" + time +
                    ", speed=" + speed +
                    ", coordinate=" + coordinate +
                    '}';
        }
    }
}
