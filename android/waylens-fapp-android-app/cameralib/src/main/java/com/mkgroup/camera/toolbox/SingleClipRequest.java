package com.mkgroup.camera.toolbox;

import com.mkgroup.camera.model.Clip;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbResponse;

import org.apache.mina.core.buffer.IoBuffer;

import java.nio.ByteOrder;

/**
 * Created by doanvt on 2019/1/23.
 * Email：doanvt-hn@mk.com.vn
 */

public class SingleClipRequest extends VdbRequest<Clip> {

    private final static String TAG = SingleClipRequest.class.getSimpleName();

    private Clip.ID mCid;
    private int type;
    private boolean isVdtCamera;

    SingleClipRequest(Clip.ID cid, int type, boolean isVdtCamera, VdbResponse.Listener<Clip> listener, VdbResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
        this.mCid = cid;
        this.type = type;
        this.isVdtCamera = isVdtCamera;
    }

    @Override
    protected VdbCommand createVdbCommand() {
        if (mMethod == ClipSetExRequest.METHOD_GET) {
            int flag = ClipSetExRequest.FLAG_CLIP_EXTRA | ClipSetExRequest.FLAG_CLIP_ATTR
                    | ClipSetExRequest.FLAG_CLIP_DESC | ClipSetExRequest.FLAG_CLIP_SCENE_DATA
//                    | FLAG_CLIP_RAW_FCC | FLAG_CLIP_VIDEO_TYPE
                    | ClipSetExRequest.FLAG_CLIP_VIDEO_DESCR;

            if (!isVdtCamera) {
                flag = flag | ClipSetExRequest.FLAG_CLIP_RAW_FCC | ClipSetExRequest.FLAG_CLIP_VIDEO_TYPE;
            }

            mVdbCommand = VdbCommand.Factory.createCmdGetClipInfo(mCid, type, flag);
        }
        return mVdbCommand;
    }

    @Override
    protected VdbResponse<Clip> parseVdbResponse(VdbAcknowledge response) {
        switch (mMethod) {
            case ClipSetExRequest.METHOD_GET:
                try {
                    return parseGetSingleClipResponse(response);
                } catch (Exception e) {
                    Logger.t(TAG).e("parse single clip failed!" + e.toString());
                }
                break;
            case ClipSetExRequest.METHOD_SET:
                break;
        }
        return null;
    }

    private VdbResponse<Clip> parseGetSingleClipResponse(VdbAcknowledge response) {
        int msgIndex = response.getMsgIndex();
        IoBuffer ioBuffer = IoBuffer.wrap(response.getByteBuffer(), msgIndex, response.getByteBuffer().length - msgIndex);
        ioBuffer.order(ByteOrder.LITTLE_ENDIAN);
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("ackGetSingleClipInfo failed: " + retCode);
            return null;
        }

        Clip clip = ClipSetExRequest.readClipInfo(ioBuffer);
        return VdbResponse.success(clip);
    }
}
