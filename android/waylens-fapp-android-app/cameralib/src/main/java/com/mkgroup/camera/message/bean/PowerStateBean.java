package com.mkgroup.camera.message.bean;

public class PowerStateBean {

    /**
     * status : Charging
     * online : true
     * level : Full
     * percent : 100
     * mv : 13125
     */

    private String status;
    private boolean online;
    private String level;
    private int percent;
    private int mv;

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isOnline() {
        return online;
    }

    public void setOnline(boolean online) {
        this.online = online;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public int getPercent() {
        return percent;
    }

    public void setPercent(int percent) {
        this.percent = percent;
    }

    public int getMv() {
        return mv;
    }

    public void setMv(int mv) {
        this.mv = mv;
    }

    @Override
    public String toString() {
        return "PowerStateBean{" +
                "status='" + status + '\'' +
                ", online=" + online +
                ", level='" + level + '\'' +
                ", percent=" + percent +
                ", mv=" + mv +
                '}';
    }
}
