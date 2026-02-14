package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.FenceRuleBean;

import java.util.List;

/**
 * Created by cloud on 2020/5/14.
 */
public class FenceRuleListResponse {

    private List<FenceRuleBean> FenceRuleList;

    public List<FenceRuleBean> getFenceRuleList() {
        return FenceRuleList;
    }

    public void setFenceRuleList(List<FenceRuleBean> FenceRuleList) {
        this.FenceRuleList = FenceRuleList;
    }
}
