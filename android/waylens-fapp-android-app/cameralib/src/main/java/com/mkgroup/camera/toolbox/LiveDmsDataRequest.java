package com.mkgroup.camera.toolbox;

import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbResponse;

import static com.mkgroup.camera.data.vdb.VdbCommand.Factory.MSG_RawData;

public class LiveDmsDataRequest extends VdbRequest<Integer> {

    private final static String TAG = LiveDmsDataRequest.class.getSimpleName();

    private final static int VDB_OPTION_NEED_EXTRA_RAW_DATA = 5;

    // enable ? MAKE_FOURCC_STR("DMS0") : 0
    private final int mParam;

    public LiveDmsDataRequest(int method, VdbResponse.Listener<Integer> listener, VdbResponse.ErrorListener errorListener) {
        super(method, listener, errorListener);
        mParam = method;
    }

    @Override
    protected VdbCommand createVdbCommand() {
        mVdbCommand = VdbCommand.Factory.createCmdSetOptions(VDB_OPTION_NEED_EXTRA_RAW_DATA, mParam);
        mVdbCommand.setAcknowledgeCode(MSG_RawData);
        return mVdbCommand;
    }

    @Override
    protected VdbResponse<Integer> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("parseVdbResponse: " + retCode);
            return null;
        }
        return VdbResponse.success(mParam);
    }
}
