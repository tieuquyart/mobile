package com.mkgroup.camera.toolbox;


import com.mkgroup.camera.model.Clip;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbResponse;


public class AddBookmarkRequest extends VdbRequest<Integer> {
    private static final String TAG = AddBookmarkRequest.class.getSimpleName();

    private final Clip.ID mClipId;
    private final long mStartTimeMs;
    private final long mEndTimeMs;

    public AddBookmarkRequest(Clip.ID cid, long startTimeMs, long endTimeMs,
                              VdbResponse.Listener<Integer> listener,
                              VdbResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
        this.mClipId = cid;
        this.mStartTimeMs = startTimeMs;
        this.mEndTimeMs = endTimeMs;
    }

    @Override
    protected VdbCommand createVdbCommand() {
        mVdbCommand = VdbCommand.Factory.createCmdAddBookmark(mClipId, mStartTimeMs, mEndTimeMs);
        return mVdbCommand;
    }

    @Override
    protected VdbResponse<Integer> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("parseVdbResponse: " + retCode);
            return null;
        }

        int error = response.readi32();
        return VdbResponse.success(error);
    }
}