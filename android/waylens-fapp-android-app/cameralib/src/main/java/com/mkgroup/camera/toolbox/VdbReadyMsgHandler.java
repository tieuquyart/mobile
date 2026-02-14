package com.mkgroup.camera.toolbox;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbMessageHandler;
import com.mkgroup.camera.data.vdb.VdbResponse;

/**
 * Created by DoanVT on 2017/8/11.
 */
public class VdbReadyMsgHandler extends VdbMessageHandler<Object> {

    private final static String TAG = VdbReadyMsgHandler.class.getSimpleName();

    public VdbReadyMsgHandler(VdbResponse.Listener<Object> listener,
                              VdbResponse.ErrorListener errorListener) {
        super(VdbCommand.Factory.MSG_VdbReady, listener, errorListener);
    }

    @Override
    protected VdbResponse<Object> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("MSG_VdbReady parseVdbResponse: " + retCode);
            return null;
        }
        Object object = new Object();
        return VdbResponse.success(object);
    }
}