package com.mkgroup.camera.data.dms;

import com.mkgroup.camera.data.SnipeError;

import java.io.IOException;

public interface ISocket {
    void performRequest(DmsRequest<?> dmsRequest) throws SnipeError;

    DmsAcknowledge retrieveAcknowledge() throws IOException;
}
