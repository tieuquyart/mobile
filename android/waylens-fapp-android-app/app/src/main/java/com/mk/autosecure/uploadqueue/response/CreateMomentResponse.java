package com.mk.autosecure.uploadqueue.response;


import com.mk.autosecure.uploadqueue.entities.UploadServer;
import com.mkgroup.camera.utils.ToStringUtils;

/**
 * Created by doanvt on 2016/6/17.
 */
public class CreateMomentResponse {
    public long momentID;
    public UploadServer uploadServer;


    @Override
    public String toString() {
        return ToStringUtils.getString(this);
    }
}
