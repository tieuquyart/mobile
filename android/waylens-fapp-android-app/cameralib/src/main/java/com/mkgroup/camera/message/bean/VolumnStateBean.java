package com.mkgroup.camera.message.bean;

public class VolumnStateBean {

    /**
     * muted : false
     * volumn : 5
     * minVolumn : 1
     * maxVolumn : 9
     */

    private boolean muted;
    private int volumn;
    private int minVolumn;
    private int maxVolumn;

    public VolumnStateBean(boolean muted, int volumn) {
        this.muted = muted;
        this.volumn = volumn;
    }

    public boolean isMuted() {
        return muted;
    }

    public void setMuted(boolean muted) {
        this.muted = muted;
    }

    public int getVolumn() {
        return volumn;
    }

    public void setVolumn(int volumn) {
        this.volumn = volumn;
    }

    public int getMinVolumn() {
        return minVolumn;
    }

    public void setMinVolumn(int minVolumn) {
        this.minVolumn = minVolumn;
    }

    public int getMaxVolumn() {
        return maxVolumn;
    }

    public void setMaxVolumn(int maxVolumn) {
        this.maxVolumn = maxVolumn;
    }
}
