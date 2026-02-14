package com.mkgroup.camera.glide_adapter;


import com.mkgroup.camera.model.ClipPos;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbRequestFuture;
import com.mkgroup.camera.data.vdb.VdbResponse;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

/**
 * Created by doanvt on 2016/6/18.
 */
public class GlideVdbRequest extends VdbRequest<InputStream> {

    private static final String TAG = GlideVdbRequest.class.getSimpleName();

    private final ClipPos mClipPos;
    private final boolean mIsIgnorable;

    public GlideVdbRequest(ClipPos clipPos, VdbRequestFuture<InputStream> future, boolean isIgnorable) {
        super(0, future, future);
        this.mClipPos = clipPos;
        this.mIsIgnorable = isIgnorable;
    }

    @Override
    protected VdbCommand createVdbCommand() {
        mVdbCommand = VdbCommand.Factory.createCmdGetIndexPicture(mClipPos);
        return mVdbCommand;
    }

    @Override
    public Priority getPriority() {
        return Priority.LOW;
    }

    @Override
    public boolean isIgnorable() {
        return mIsIgnorable;
    }

    @Override
    protected VdbResponse<InputStream> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("ackGetIndexPicture failed: " + retCode);
            return null;
        }

        int clipType = response.readi32();
        int clipId = response.readi32();
        int clipDate = response.readi32();
        int type = response.readi32();
        boolean bIsLast = (type & ClipPos.F_IS_LAST) != 0;
        type &= ~ClipPos.F_IS_LAST;
        long timeMs = response.readi64();
        long clipStartTime = response.readi64();
        int clipDuration = response.readi32();

        int pictureSize = response.readi32();
        byte[] data = new byte[pictureSize];
        response.readByteArray(data, pictureSize);
        return VdbResponse.success(new ByteArrayInputStream(data));
    }
}
