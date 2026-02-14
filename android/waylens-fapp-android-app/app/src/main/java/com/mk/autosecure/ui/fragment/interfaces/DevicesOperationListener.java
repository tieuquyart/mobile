package com.mk.autosecure.ui.fragment.interfaces;

import android.view.View;

import com.mkgroup.camera.bean.FleetCameraBean;

public interface DevicesOperationListener {
    void onClickDeviceItem(FleetCameraBean bean, View view);
    void onAddDevice();
}
