package com.mkgroup.camera.message.bean;

import java.io.Serializable;

/**
 * Created by cloud on 2022/4/19.
 */
public class AuxCfgModel implements Serializable {

    private int model; // 设备预制model; 0=NA, 1=ecm02(aux); 2=ecm01(dms)
    private int angle; // degree index; 0=normal, 1=90, 2=180, 3=270
    private int plug; // 当前实际接入设备; value same as model

    public AuxCfgModel(int model, int angle, int plug) {
        this.model = model;
        this.angle = angle;
        this.plug = plug;
    }

    public int getModel() {
        return model;
    }

    public void setModel(int model) {
        this.model = model;
    }

    public int getAngle() {
        return angle;
    }

    public void setAngle(int angle) {
        this.angle = angle;
    }

    public int getPlug() {
        return plug;
    }

    public void setPlug(int plug) {
        this.plug = plug;
    }

    @Override
    public String toString() {
        return "AuxCfgModel{" +
                "model=" + model +
                ", angle=" + angle +
                ", plug=" + plug +
                '}';
    }
}
