package com.mk.autosecure.libs.account;

import com.mk.autosecure.HornApplication;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.bean.CameraBean;
import com.mk.autosecure.libs.utils.SortUtil;
import com.mk.autosecure.rest.BaseObserver;
import com.mk.autosecure.rest.reponse.DeviceListResponse;

import java.util.ArrayList;

/**
 * Created by DoanVT on 2017/12/4.
 * Email: doanvt-hn@mk.com.vn
 */

public class CameraSubscriber extends BaseObserver<DeviceListResponse> {

    private final static String TAG = CameraSubscriber.class.getSimpleName();

    public CameraSubscriber() {
        super();
    }

    @Override
    protected void onHandleSuccess(DeviceListResponse data) {
        Logger.t(TAG).d("cameras: " + data.cameras);
        ArrayList<CameraBean> cameras = data.cameras;
        HornApplication.getComponent().currentUser().refreshDevices(SortUtil.sort(cameras), false);
    }

}
