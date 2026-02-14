package com.mkgroup.camera.toolbox;

import com.mkgroup.camera.bean.ClipSegment;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipDownloadInfo;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.data.vdb.VdbAcknowledge;
import com.mkgroup.camera.data.vdb.VdbCommand;
import com.mkgroup.camera.data.vdb.VdbRequest;
import com.mkgroup.camera.data.vdb.VdbResponse;

/**
 * Created by DoanVT on 2017/9/28.
 */

public class DownloadUrlRequest extends VdbRequest<ClipDownloadInfo> {
    private static final String TAG = DownloadUrlRequest.class.getSimpleName();
    private ClipSegment mClipSegment;
    private int mStreamIndex;
    private Clip.ID cid;

    private boolean isPlaylist = false;
    private long mStartTime;
    private int mLength;

    private int downloadStream = DOWNLOAD_OPT_MAIN_STREAM;

    public static final int DOWNLOAD_OPT_MAIN_STREAM = (1 << 0);
    public static final int DOWNLOAD_OPT_SUB_STREAM_1 = (1 << 1);
    public static final int DOWNLOAD_OPT_INDEX_PICT = (1 << 2);
    public static final int DOWNLOAD_OPT_PLAYLIST = (1 << 3);
    public static final int DOWNLOAD_OPT_MUTE_AUDIO = (1 << 4);
    public static final int DOWNLOAD_OPT_MAIN_MP4 = (1 << 5);
    public static final int DOWNLOAD_OPT_SUB_MP4 = (1 << 6);
    public static final int DOWNLOAD_OPT_SUB_STREAM_N = (1 << 7);
    public static final int DOWNLOAD_OPT_SUB_N_MP4 = (1 << 8);

    public DownloadUrlRequest(ClipSegment clipSegment, VdbResponse.Listener<ClipDownloadInfo> listener,
                              VdbResponse.ErrorListener errorListener) {
        this(clipSegment, DOWNLOAD_OPT_SUB_STREAM_1, listener, errorListener);
    }

    public DownloadUrlRequest(ClipSegment clipSegment, int streamIndex, VdbResponse.Listener<ClipDownloadInfo> listener,
                              VdbResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
        this.mClipSegment = clipSegment;
        this.mStreamIndex = streamIndex;
    }

    public DownloadUrlRequest(Clip.ID cid, long start, int length, int downloadStream, int streamIndex, VdbResponse.Listener<ClipDownloadInfo> listener,
                              VdbResponse.ErrorListener errorListener) {
        super(0, listener, errorListener);
        this.cid = cid;
        this.mStartTime = start;
        this.mLength = length;
        this.downloadStream = downloadStream;
        this.mStreamIndex = streamIndex;
    }


    @Override
    protected VdbCommand createVdbCommand() {
        int downloadOption;

        if (downloadStream == DOWNLOAD_OPT_MAIN_STREAM) {
            downloadOption = DOWNLOAD_OPT_MAIN_STREAM;
        } else if (downloadStream == DOWNLOAD_OPT_SUB_STREAM_1) {
            downloadOption = DOWNLOAD_OPT_SUB_STREAM_1;
        } else {
            downloadOption = DOWNLOAD_OPT_SUB_STREAM_N;
        }

        downloadOption += mStreamIndex << 16;

        if (isPlaylist) {
            downloadOption |= DOWNLOAD_OPT_PLAYLIST;
        }
        mVdbCommand = VdbCommand.Factory.createCmdGetClipDownloadUrl(cid, mStartTime, mLength, downloadOption, true);
        return mVdbCommand;
    }

    @Override
    protected VdbResponse<ClipDownloadInfo> parseVdbResponse(VdbAcknowledge response) {
        int retCode = response.getRetCode();
        if (retCode != 0) {
            Logger.t(TAG).e("ackGetDownloadUrl failed: " + retCode);
            return null;
        }

        int clipType = response.readi32();
        int clipId = response.readi32();
        Clip.ID cid = new Clip.ID(clipType, clipId, null);
        ClipDownloadInfo clipDownloadInfo = new ClipDownloadInfo(cid);

        int download_opt = response.readi32();
        clipDownloadInfo.opt = download_opt;

        if ((download_opt & DOWNLOAD_OPT_MAIN_STREAM) != 0) {
            clipDownloadInfo.main.clipDate = response.readi32();
            clipDownloadInfo.main.clipTimeMs = response.readi64();
            clipDownloadInfo.main.lengthMs = response.readi32();
            clipDownloadInfo.main.size = response.readi64();
            clipDownloadInfo.main.url = response.readString();
        }

        if ((download_opt & DOWNLOAD_OPT_SUB_STREAM_1) != 0) {
            clipDownloadInfo.sub.clipDate = response.readi32();
            clipDownloadInfo.sub.clipTimeMs = response.readi64();
            clipDownloadInfo.sub.lengthMs = response.readi32();
            clipDownloadInfo.sub.size = response.readi64(); // ？？？java.lang.ArrayIndexOutOfBoundsException: length=160; index=160
            clipDownloadInfo.sub.url = response.readString();
        }

        if ((download_opt & DOWNLOAD_OPT_SUB_STREAM_N) != 0) {
            clipDownloadInfo.subN.clipDate = response.readi32();
            clipDownloadInfo.subN.clipTimeMs = response.readi64();
            clipDownloadInfo.subN.lengthMs = response.readi32();
            clipDownloadInfo.subN.size = response.readi64();
            clipDownloadInfo.subN.url = response.readString();
        }

        if ((download_opt & DOWNLOAD_OPT_INDEX_PICT) != 0) {
            int pictureSize = response.readi32();
            clipDownloadInfo.posterData = new byte[pictureSize];
            response.readByteArray(clipDownloadInfo.posterData, pictureSize);
        }

        return VdbResponse.success(clipDownloadInfo);
    }
}
