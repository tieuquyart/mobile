package com.mkgroup.camera.toolbox;

import com.mkgroup.camera.model.SpaceInfo;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbResponse;

/**
 * Created by doanvt on 2016/5/5.
 */
public class GetSpaceInfoRequest extends VdbRequest<SpaceInfo> {
    private static final String TAG = GetSpaceInfoRequest.class.getSimpleName();

    public GetSpaceInfoRequest(VdbResponse.Listener<SpaceInfo> listener, VdbResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
    }

    @Override
    protected VdbCommand createVdbCommand() {
        mVdbCommand = VdbCommand.Factory.createCmdGetSpaceInfo();
        return mVdbCommand;
    }

    @Override
    protected VdbResponse<SpaceInfo> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("parseVdbResponse: " + retCode);
            return null;
        }

        SpaceInfo spaceInfo = new SpaceInfo();

        spaceInfo.total = response.readi64();
        spaceInfo.used = response.readi64();
        spaceInfo.marked = response.readi64();
        spaceInfo.clip = response.readi64();

        return VdbResponse.success(spaceInfo);
    }
}
