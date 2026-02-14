package com.mkgroup.camera.toolbox;

import android.os.Bundle;

import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.PlaybackUrl;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbResponse;


public class ClipPlaybackUrlExRequest extends ClipPlaybackUrlRequest {

    public static final String PARAMETER_CLIP_LENGTH_MS = "clip_length_ms";

    public ClipPlaybackUrlExRequest(Clip.ID cid, Bundle parameters,
                                    VdbResponse.Listener<PlaybackUrl> listener,
                                    VdbResponse.ErrorListener errorListener) {
        this(0, cid, parameters, listener, errorListener);
    }

    public ClipPlaybackUrlExRequest(int method, Clip.ID cid, Bundle parameters,
                                    VdbResponse.Listener<PlaybackUrl> listener,
                                    VdbResponse.ErrorListener errorListener) {
        super(method, cid, parameters, listener, errorListener);
    }

    @Override
    protected VdbCommand createVdbCommand() {
        int stream = mParameters.getInt(PARAMETER_STREAM);
        int urlType = mParameters.getInt(PARAMETER_URL_TYPE);
        boolean muteAudio = mParameters.getBoolean(PARAMETER_MUTE_AUDIO);
        long clipTimeMs = mParameters.getLong(PARAMETER_CLIP_TIME_MS);
        int clipLengthMs = mParameters.getInt(PARAMETER_CLIP_LENGTH_MS, 0);
        mVdbCommand = VdbCommand.Factory.createCmdGetClipPlaybackUrl(mCid, stream, urlType,
                muteAudio, clipTimeMs, clipLengthMs);
        return mVdbCommand;
    }
}
