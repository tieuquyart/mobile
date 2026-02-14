package com.mkgroup.camera.toolbox;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbResponse;

/**
 * Created by DoanVT on 2017/11/29.
 * Email: doanvt-hn@mk.com.vn
 */


public class LiveRawDataRequest extends VdbRequest<Integer> {
    private static final String TAG = LiveRawDataRequest.class.getSimpleName();
    private final int mDataType;

    public LiveRawDataRequest(int dataType,
                              VdbResponse.Listener<Integer> listener,
                              VdbResponse.ErrorListener errorListener
    ) {
        super(0, listener, errorListener);
        this.mDataType = dataType;
    }

    @Override
    protected VdbCommand createVdbCommand() {
        mVdbCommand = VdbCommand.Factory.createCmdSetRawDataOption(mDataType);
        return mVdbCommand;
    }

    @Override
    protected VdbResponse<Integer> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("parseVdbResponse: " + retCode);
            return null;
        }
        return VdbResponse.success(mDataType);
    }
}
