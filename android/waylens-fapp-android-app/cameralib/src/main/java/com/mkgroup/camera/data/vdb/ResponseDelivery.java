package com.mkgroup.camera.data.vdb;

import com.mkgroup.camera.data.SnipeError;

/**
 * Created by doanvt on 2015/8/17.
 */

public interface ResponseDelivery {
    void postResponse(VdbRequest<?> vdbRequest, VdbResponse<?> vdbResponse);

    void postResponse(VdbRequest<?> vdbRequest, VdbResponse<?> vdbResponse, Runnable runnable);

    void postError(VdbRequest<?> vdbRequest, SnipeError error);
}
