package com.mk.autosecure.rest.reponse;

import com.mkgroup.camera.bean.ClipBean;

import java.util.List;

/**
 * Created by DoanVT on 2017/8/31.
 */

public class ClipListResponse {
    public List<ClipBean> clips;
    public Boolean hasmore;

    @Override
    public String toString() {
        return "ClipListResponse{" +
                "clips=" + clips +
                ", hasmore=" + hasmore +
                '}';
    }
}
