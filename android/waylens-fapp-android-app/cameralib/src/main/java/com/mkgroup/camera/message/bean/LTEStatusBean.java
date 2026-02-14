package com.mkgroup.camera.message.bean;

public class LTEStatusBean {

    /**
     * sim : READY
     * cereg : 0,1
     * cops : 0,0,"CHN-CT",7
     * network : "LTE","PS_ONLY","FDD"
     * band : LTE: 2,4,5,12
     * signal : 207,2452,"-101.40"
     * csq : 17,99
     * cellinfo : 0X5D1C,0X05BB9654,0X000000CF,LTE B5,2452
     * ip : IPV4, 100.97.140.230, 100.97.140.229, 116.236.159.8, 222.66.251.8
     * ping8888 : true
     * connected : true
     */

    private String sim;
    private String cereg;
    private String cops;
    private String network;
    private String band;
    private String signal;
    private String csq;
    private String cellinfo;
    private String ip;
    private boolean ping8888;
    private boolean connected;

    public String getSim() {
        return sim;
    }

    public void setSim(String sim) {
        this.sim = sim;
    }

    public String getCereg() {
        return cereg;
    }

    public void setCereg(String cereg) {
        this.cereg = cereg;
    }

    public String getCops() {
        return cops;
    }

    public void setCops(String cops) {
        this.cops = cops;
    }

    public String getNetwork() {
        return network;
    }

    public void setNetwork(String network) {
        this.network = network;
    }

    public String getBand() {
        return band;
    }

    public void setBand(String band) {
        this.band = band;
    }

    public String getSignal() {
        return signal;
    }

    public void setSignal(String signal) {
        this.signal = signal;
    }

    public String getCsq() {
        return csq;
    }

    public void setCsq(String csq) {
        this.csq = csq;
    }

    public String getCellinfo() {
        return cellinfo;
    }

    public void setCellinfo(String cellinfo) {
        this.cellinfo = cellinfo;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public boolean isPing8888() {
        return ping8888;
    }

    public void setPing8888(boolean ping8888) {
        this.ping8888 = ping8888;
    }

    public boolean isConnected() {
        return connected;
    }

    public void setConnected(boolean connected) {
        this.connected = connected;
    }
}
