package com.mkgroup.camera.message.bean;

import com.google.gson.annotations.SerializedName;

public class ModeVisionBean {

    @SerializedName("trackingPlate")
    private boolean trackingPlate;

    @SerializedName("stopParking")
    private boolean stopParking;

    @SerializedName("overSpeed")
    private boolean overSpeed;

    // Getter
    public boolean gettrackingPlate() { return trackingPlate; }
    public boolean getStopParking() { return stopParking; }
    public boolean getOverSpeed() { return overSpeed; }

    // Setter
    public void setTrackingPlate(boolean trackingPlate) { this.trackingPlate = trackingPlate; }
    public void setStopParking(boolean stopParking) { this.stopParking = stopParking; }
    public void setOverSpeed(boolean overSpeed) { this.overSpeed = overSpeed; }
}
