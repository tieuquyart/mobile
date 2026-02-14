package com.mkgroup.camera.toolbox;

import com.mkgroup.camera.model.ClipActionInfo;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbResponse;

/**
 * Created by DoanVT on 2017/8/11.
 */
public class MarkLiveMsgHandler extends ClipInfoMsgHandler {

    public MarkLiveMsgHandler(VdbResponse.Listener<ClipActionInfo> listener,
                              VdbResponse.ErrorListener errorListener) {
        super(VdbCommand.Factory.MSG_MarkLiveClipInfo, listener, errorListener);
    }

    @Override
    protected VdbResponse<ClipActionInfo> parseVdbResponse(VdbAcknowledge response) {
        VdbResponse<ClipActionInfo> vdbResponse = super.parseVdbResponse(response);

        ClipActionInfo.MarkLiveInfo info = new ClipActionInfo.MarkLiveInfo();
        info.flags = response.readi32(); // flags, not used
        info.delay_ms = response.readi32();
        info.before_live_ms = response.readi32();
        info.after_live_ms = response.readi32();

        vdbResponse.result.markLiveInfo = info;

        return VdbResponse.success(vdbResponse.result);
    }
}