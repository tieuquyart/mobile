package com.mk.autosecure.ui.fragment.interfaces;

import android.view.View;

import com.mk.autosecure.rest_fleet.bean.VehicleInfoBean;

public interface VehiclesOperationListener {
    void onClickVehicleItem(VehicleInfoBean bean, View view);

    void onAddVehicle();
}
