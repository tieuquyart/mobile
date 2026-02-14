package com.mk.autosecure.rest_fleet.response;

import com.mk.autosecure.rest_fleet.bean.BillingDataBean;

import java.util.List;

public class BillingDataResponse {

    private List<BillingDataBean> billings;

    public List<BillingDataBean> getBillings() {
        return billings;
    }

    public void setBillings(List<BillingDataBean> billings) {
        this.billings = billings;
    }
}
