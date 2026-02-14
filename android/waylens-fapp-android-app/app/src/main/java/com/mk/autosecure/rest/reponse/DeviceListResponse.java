package com.mk.autosecure.rest.reponse;

import com.mk.autosecure.rest_fleet.response.Response;
import com.mkgroup.camera.bean.CameraBean;

import java.io.Serializable;
import java.util.ArrayList;

/**
 * Created by DoanVT on 2017/8/9.
 */

public class DeviceListResponse extends Response implements Serializable {

    public ArrayList<CameraBean> cameras;

    @Override
    public String toString() {
        return "DeviceListResponse{" +
                "cameras=" + cameras +
                '}';
    }
}
