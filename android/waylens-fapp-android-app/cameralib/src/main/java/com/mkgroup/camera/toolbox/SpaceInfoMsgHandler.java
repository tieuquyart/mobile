package com.mkgroup.camera.toolbox;


import com.mkgroup.camera.model.SpaceInfo;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbMessageHandler;
import com.mkgroup.camera.data.vdb.VdbResponse;

/**
 * Created by DoanVT on 2017/12/1.
 * Email: doanvt-hn@mk.com.vn
 */

public class SpaceInfoMsgHandler extends VdbMessageHandler<SpaceInfo> {

    private final static String TAG = SpaceInfoMsgHandler.class.getSimpleName();

    public SpaceInfoMsgHandler(VdbResponse.Listener<SpaceInfo> listener,
                               VdbResponse.ErrorListener errorListener) {
        super(VdbCommand.Factory.MSG_SpaceInfo, listener, errorListener);
    }

    @Override
    protected VdbResponse<SpaceInfo> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("MSG_SpaceInfo parseVdbResponse failed: " + retCode);
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