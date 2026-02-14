package com.mkgroup.camera.event;

import com.mkgroup.camera.CameraWrapper;

import java.util.List;

/**
 * Created by doanvt on 2018/6/27.
 * Email：doanvt-hn@mk.com.vn
 */

public class HostsChangeEvent {
    private final CameraWrapper mCamera;
    private final List<String> mSsidList;

    public HostsChangeEvent(CameraWrapper camera, List<String> list) {
        this.mCamera = camera;
        this.mSsidList = list;
    }

    public CameraWrapper getCamera() {
        return mCamera;
    }

    public List<String> getSsidList() {
        return mSsidList;
    }

}
