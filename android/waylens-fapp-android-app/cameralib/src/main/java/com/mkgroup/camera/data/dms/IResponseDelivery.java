package com.mkgroup.camera.data.dms;

import com.mkgroup.camera.data.SnipeError;

public interface IResponseDelivery {
    void postResponse(DmsRequest<?> dmsRequest, DmsResponse<?> dmsResponse);

    void postResponse(DmsRequest<?> dmsRequest, DmsResponse<?> dmsResponse, Runnable runnable);

    void postError(DmsRequest<?> dmsRequest, SnipeError error);
}
