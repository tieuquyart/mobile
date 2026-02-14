package com.mkgroup.camera.toolbox;

import android.os.Bundle;

import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipDownloadInfo;
import com.mkgroup.camera.model.PlaybackUrl;
import com.mkgroup.camera.model.SpaceInfo;
import com.mkgroup.camera.model.VdbConsts;
import com.mkgroup.camera.model.rawdata.RawDataBlock;
import com.mkgroup.camera.data.vdb.VdbRequestFuture;
import com.mkgroup.camera.model.rawdata.RawDataItem;

import java.util.concurrent.ExecutionException;

import io.reactivex.Observable;

/**
 * Created by DoanVT on 2017/8/2.
 */

public class SnipeApi {

    public static PlaybackUrl getClipPlaybackUrl(Clip.ID clipId, long startTime, long clipTimeMs, int maxLength) throws ExecutionException, InterruptedException {
        return getClipPlaybackUrlWithStream(clipId, startTime, clipTimeMs, maxLength, 0);
    }

    public static PlaybackUrl getClipPlaybackUrlWithStream(Clip.ID clipId, long startTime, long clipTimeMs, int maxLength, int streamIndex) throws ExecutionException, InterruptedException {
        Bundle parameters = new Bundle();
        parameters.putInt(ClipPlaybackUrlExRequest.PARAMETER_URL_TYPE, VdbConsts.URL_TYPE_HLS);
        parameters.putInt(ClipPlaybackUrlExRequest.PARAMETER_STREAM, streamIndex);
        parameters.putBoolean(ClipPlaybackUrlExRequest.PARAMETER_MUTE_AUDIO, false);
        parameters.putLong(ClipPlaybackUrlExRequest.PARAMETER_CLIP_TIME_MS, clipTimeMs + startTime);
        parameters.putInt(ClipPlaybackUrlExRequest.PARAMETER_CLIP_LENGTH_MS, maxLength);

        VdbRequestFuture<PlaybackUrl> requestFuture = VdbRequestFuture.newFuture();
        ClipPlaybackUrlExRequest request = new ClipPlaybackUrlExRequest(clipId, parameters, requestFuture, requestFuture);
        VdtCameraManager.getManager().getCurrentVdbRequestQueue().add(request);
        return requestFuture.get();
    }

    public static ClipDownloadInfo getClipDownloadInfo(Clip.ID cid, long start, int length, int downloadStream, int streamIndex) throws ExecutionException, InterruptedException {
        VdbRequestFuture<ClipDownloadInfo> requestFuture = VdbRequestFuture.newFuture();
        DownloadUrlRequest request = new DownloadUrlRequest(cid, start, length, downloadStream, streamIndex, requestFuture, requestFuture);
        VdtCameraManager.getManager().getCurrentVdbRequestQueue().add(request);
        return requestFuture.get();
    }

    public static Integer addHighlight(Clip.ID clipId, long startTimeMs, long endTimeMs) throws ExecutionException, InterruptedException {
        VdbRequestFuture<Integer> requestFuture = VdbRequestFuture.newFuture();
        AddBookmarkRequest request = new AddBookmarkRequest(clipId, startTimeMs, endTimeMs, requestFuture, requestFuture);
        VdtCameraManager.getManager().getCurrentVdbRequestQueue().add(request);
        return requestFuture.get();
    }

    public static Integer deleteClip(Clip.ID clipId) throws ExecutionException, InterruptedException {
        VdbRequestFuture<Integer> future = VdbRequestFuture.newFuture();
        ClipDeleteRequest request = new ClipDeleteRequest(clipId, future, future);
        VdtCameraManager.getManager().getCurrentVdbRequestQueue().add(request);
        return future.get();
    }

    public static SpaceInfo getSpaceInfo() throws ExecutionException, InterruptedException {
        VdbRequestFuture<SpaceInfo> future = VdbRequestFuture.newFuture();
        GetSpaceInfoRequest request = new GetSpaceInfoRequest(future, future);
        VdtCameraManager.getManager().getCurrentVdbRequestQueue().add(request);
        return future.get();
    }

    public static Observable<RawDataBlock> getRawDataBlockRx(final Clip clip, final int dataType, final long startTime, final int duration) {
        return Observable.defer(() -> Observable.just(SnipeApi.getRawDataBlock(clip, dataType, startTime, duration)));
    }

    public static RawDataBlock getRawDataBlock(Clip clip, int dataType, long startTime, int duration) {
        Bundle params = new Bundle();
        params.putInt(RawDataBlockRequest.PARAM_DATA_TYPE, dataType);
        params.putLong(RawDataBlockRequest.PARAM_CLIP_TIME, startTime);
        params.putInt(RawDataBlockRequest.PARAM_CLIP_LENGTH, duration);

        VdbRequestFuture<RawDataBlock> requestFuture = VdbRequestFuture.newFuture();
        RawDataBlockRequest request = new RawDataBlockRequest(clip.cid, params, requestFuture, requestFuture);
        VdtCameraManager.getManager().getCurrentVdbRequestQueue().add(request);
        try {
            return requestFuture.get();
        } catch (InterruptedException | ExecutionException e) {
            return null;
        }
    }

    public static Observable<Integer> addHighlightRx(final Clip.ID clipId, final long startTimeMs, final long endTimeMs) {
        return Observable.defer(() -> {
            try {
                return Observable.just(SnipeApi.addHighlight(clipId, startTimeMs, endTimeMs));
            } catch (ExecutionException | InterruptedException e) {
                return Observable.error(e);
            }
        });
    }

    public static Observable<Clip> getSingleClipRx(Clip.ID cid, int type, boolean isVdtCamera) {
        return Observable.defer(() -> {
            try {
                return Observable.just(SnipeApi.getSingleClip(cid, type, isVdtCamera));
            } catch (ExecutionException | InterruptedException e) {
                return Observable.error(e);
            }
        });
    }

    public static Clip getSingleClip(Clip.ID cid, int type, boolean isVdtCamera) throws ExecutionException, InterruptedException {
        VdbRequestFuture<Clip> future = VdbRequestFuture.newFuture();
        SingleClipRequest request = new SingleClipRequest(cid, type, isVdtCamera, future, future);
        VdtCameraManager.getManager().getCurrentVdbRequestQueue().add(request);
        return future.get();
    }

    public static Observable<Integer> getLiveDmsDataRx(final boolean enable) {
        return Observable.defer(() -> {
            try {
                return Observable.just(SnipeApi.getLiveDmsData(enable));
            } catch (ExecutionException | InterruptedException e) {
                return Observable.error(e);
            }
        });
    }

    private static Integer getLiveDmsData(boolean enable) throws ExecutionException, InterruptedException {
        VdbRequestFuture<Integer> future = VdbRequestFuture.newFuture();
        LiveDmsDataRequest request = new LiveDmsDataRequest(enable ? RawDataItem.DATA_TYPE_DMS1 : 0, future, future);
        VdtCameraManager.getManager().getCurrentVdbRequestQueue().add(request);
        return future.get();
    }
}
