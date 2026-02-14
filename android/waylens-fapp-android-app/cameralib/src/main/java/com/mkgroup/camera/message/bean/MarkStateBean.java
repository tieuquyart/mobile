package com.mkgroup.camera.message.bean;

public class MarkStateBean {
    /**
     * state : none
     * before : 0
     * after : 0
     */

    private String state;
    private int before;
    private int after;

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public int getBefore() {
        return before;
    }

    public void setBefore(int before) {
        this.before = before;
    }

    public int getAfter() {
        return after;
    }

    public void setAfter(int after) {
        this.after = after;
    }
}
