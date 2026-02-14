package com.mkgroup.camera.model.rawdata;

import java.io.Serializable;

/**
 * Created by cloud on 2021/5/12.
 */
public class DmsRect implements Serializable {

    public float xc; // X axis value in pixels of the rectangle center within data frame. \n\n The default value is: 0.F
    public float yc; // Y axis value in pixels of the rectangle center within data frame. \n\n The default value is: 0.F
    public float width; // Rectangular width in pixels within data frame. \n\n The default value is: 0.F
    public float height; // Rectangular height in pixels within data frame. \n\n The default value is: 0.F
    public float angle; // Rectangle rotation positive values is counterclockwise. \n\n The default value is: 0.F

    @Override
    public String toString() {
        return "DmsRect{" +
                "xc=" + xc +
                ", yc=" + yc +
                ", width=" + width +
                ", height=" + height +
                ", angle=" + angle +
                '}';
    }
}
