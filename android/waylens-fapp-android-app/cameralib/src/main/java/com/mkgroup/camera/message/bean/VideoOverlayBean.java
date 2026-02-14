package com.mkgroup.camera.message.bean;

public class VideoOverlayBean {

    /**
     * showName : false
     * showTime : true
     * showGPS : true
     * showSpeed : false
     * showLogo : true
     * useMPH : false
     */

    private boolean showName;
    private boolean showTime;
    private boolean showGPS;
    private boolean showSpeed;
    private boolean showLogo;
    private boolean useMPH;

    public boolean isShowName() {
        return showName;
    }

    public void setShowName(boolean showName) {
        this.showName = showName;
    }

    public boolean isShowTime() {
        return showTime;
    }

    public void setShowTime(boolean showTime) {
        this.showTime = showTime;
    }

    public boolean isShowGPS() {
        return showGPS;
    }

    public void setShowGPS(boolean showGPS) {
        this.showGPS = showGPS;
    }

    public boolean isShowSpeed() {
        return showSpeed;
    }

    public void setShowSpeed(boolean showSpeed) {
        this.showSpeed = showSpeed;
    }

    public boolean isShowLogo() {
        return showLogo;
    }

    public void setShowLogo(boolean showLogo) {
        this.showLogo = showLogo;
    }

    public boolean isUseMPH() {
        return useMPH;
    }

    public void setUseMPH(boolean useMPH) {
        this.useMPH = useMPH;
    }
}
