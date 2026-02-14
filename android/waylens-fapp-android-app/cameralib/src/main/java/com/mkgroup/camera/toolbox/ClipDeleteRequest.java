package com.mkgroup.camera.toolbox;


import com.mkgroup.camera.model.Clip;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbResponse;


public class ClipDeleteRequest extends VdbRequest<Integer> {
    private static final String TAG = "ClipDeleteRequest";

    private Clip.ID mCid;

    public ClipDeleteRequest(Clip.ID cid, VdbResponse.Listener<Integer> listener,
                             VdbResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
        mCid = cid;
    }

    @Override
    protected VdbCommand createVdbCommand() {
        mVdbCommand = VdbCommand.Factory.createCmdClipDelete(mCid);
        return mVdbCommand;
    }

    @Override
    protected VdbResponse<Integer> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("ClipDeleteRequest failed: " + retCode);
            return null;
        }
        int error = response.readi32();
        return VdbResponse.success(error);
    }
}
