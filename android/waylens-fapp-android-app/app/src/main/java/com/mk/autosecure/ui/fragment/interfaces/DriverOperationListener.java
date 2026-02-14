package com.mk.autosecure.ui.fragment.interfaces;

import android.view.View;

import com.mk.autosecure.rest_fleet.bean.DriverInfoBean;

public interface DriverOperationListener {
    void onClickDriverItem(DriverInfoBean bean, View view);
    void onAddDriver();
}
