package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.FenceListBean;

import java.util.List;

/**
 * Created by cloud on 2020/5/14.
 */
public class FenceListResponse {

    private List<FenceListBean> fenceList;

    public List<FenceListBean> getFenceList() {
        return fenceList;
    }

    public void setFenceList(List<FenceListBean> fenceList) {
        this.fenceList = fenceList;
    }

}
