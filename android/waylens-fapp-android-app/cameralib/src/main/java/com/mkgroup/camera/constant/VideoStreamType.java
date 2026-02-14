package com.mkgroup.camera.constant;

import java.io.Serializable;

/**
 * Created by cloud on 2020/6/12.
 */
public enum VideoStreamType implements Serializable {

    // [FRONT_HD("Road"), INCABIN_HD("In-cab"), STREAMING("Panorama"), DMS("Driver")]

    Panorama("STREAMING"), Road("FRONT_HD"), Incab("INCABIN_HD"), Driver("DMS");

    public String streamType;

    VideoStreamType(String streamType) {
        this.streamType = streamType;
    }
}
