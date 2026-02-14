package com.mkgroup.camera.data.vdb;

import com.mkgroup.camera.data.SnipeError;

import java.io.IOException;

/**
 * Created by doanvt on 2015/8/18.
 */
public interface VdbSocket {
    void performRequest(VdbRequest<?> vdbRequest) throws SnipeError;

    VdbAcknowledge retrieveAcknowledge() throws IOException;
}
