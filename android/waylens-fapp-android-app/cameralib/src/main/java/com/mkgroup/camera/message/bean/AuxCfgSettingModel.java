package com.mkgroup.camera.message.bean;

import java.io.Serializable;

/**
 * Created by cloud on 2022/4/20.
 */
public class AuxCfgSettingModel implements Serializable {

    private AuxCfgModel model; // optional
    private int angle;

    public AuxCfgSettingModel(AuxCfgModel model, int angle) {
        this.model = model;
        this.angle = angle;
    }

    public AuxCfgModel getModel() {
        return model;
    }

    public void setModel(AuxCfgModel model) {
        this.model = model;
    }

    public int getAngle() {
        return angle;
    }

    public void setAngle(int angle) {
        this.angle = angle;
    }

    @Override
    public String toString() {
        return "AuxCfgSettingModel{" +
                "model=" + model +
                ", angle=" + angle +
                '}';
    }
}
