package com.mkgroup.camera.message.bean;

import com.google.gson.annotations.SerializedName;

public class ExboardBean {


    @SerializedName("portUSB")
    private String portUSB;

    @SerializedName("version")
    private String version;

    // Getter

    public String getPortUSB() { return portUSB; }
    public String getVersionEX() { return version; }

    // Setter

    public void setPortUSB( String portUSB) { this.portUSB = portUSB; }
    public void setVersionEX(String version) { this.version = version; }
}
