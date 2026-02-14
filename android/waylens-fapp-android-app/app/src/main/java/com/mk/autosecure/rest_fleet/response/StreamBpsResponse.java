package com.mk.autosecure.rest_fleet.response;

public class StreamBpsResponse {

    /**
     * uptime : 6
     * bytesIn : 1173314
     * bytesOut : 1038155
     * bytesInRate : 168241
     * bytesOutRate : 184364
     * connectionCount : 1
     */

    private int uptime;
    private int bytesIn;
    private int bytesOut;
    private int bytesInRate;
    private int bytesOutRate;
    private int connectionCount;

    public int getUptime() {
        return uptime;
    }

    public void setUptime(int uptime) {
        this.uptime = uptime;
    }

    public int getBytesIn() {
        return bytesIn;
    }

    public void setBytesIn(int bytesIn) {
        this.bytesIn = bytesIn;
    }

    public int getBytesOut() {
        return bytesOut;
    }

    public void setBytesOut(int bytesOut) {
        this.bytesOut = bytesOut;
    }

    public int getBytesInRate() {
        return bytesInRate;
    }

    public void setBytesInRate(int bytesInRate) {
        this.bytesInRate = bytesInRate;
    }

    public int getBytesOutRate() {
        return bytesOutRate;
    }

    public void setBytesOutRate(int bytesOutRate) {
        this.bytesOutRate = bytesOutRate;
    }

    public int getConnectionCount() {
        return connectionCount;
    }

    public void setConnectionCount(int connectionCount) {
        this.connectionCount = connectionCount;
    }
}
