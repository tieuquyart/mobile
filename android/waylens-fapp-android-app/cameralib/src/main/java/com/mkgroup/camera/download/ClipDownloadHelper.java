package com.mkgroup.camera.download;

import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipDownloadInfo;
import com.orhanobut.logger.Logger;
import com.transee.vdb.HttpRemuxer;
import com.transee.vdb.RemuxerParams;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;

/**
 * Created by DoanVT on 2017/9/28.
 */


public class ClipDownloadHelper {
    private static final String TAG = ClipDownloadHelper.class.getSimpleName();
    private final Clip.StreamInfo mStreamInfo;
    private final ClipDownloadInfo.StreamDownloadInfo mDownloadInfo;
    private HttpRemuxer remuxer = new HttpRemuxer(0);

    public ClipDownloadHelper(Clip.StreamInfo streamInfo,
                              ClipDownloadInfo.StreamDownloadInfo downloadInfo) {
        this.mStreamInfo = streamInfo;
        this.mDownloadInfo = downloadInfo;

    }

    public Observable<Integer> downloadClipRx(final String outputFile) {
        return Observable.create(emitter -> ClipDownloadHelper.this.doDownloadClip(outputFile, emitter));
    }

    public void release() {
        remuxer.release();
    }


    private void doDownloadClip(String outputFile, ObservableEmitter<? super Integer> subscriber) {
        RemuxerParams params = new RemuxerParams();
        // clip params
        params.setClipDate(mDownloadInfo.clipDate);
        params.setClipTimeMs(mDownloadInfo.clipTimeMs);
        params.setClipLength(mDownloadInfo.lengthMs);
        params.setDurationMs(mDownloadInfo.lengthMs);
        // stream info
        params.setStreamVersion(mStreamInfo.version);
        params.setVideoCoding(mStreamInfo.video_coding);
        params.setVideoFrameRate(mStreamInfo.video_framerate);
        params.setVideoWidth(mStreamInfo.video_width);
        params.setVideoHeight(mStreamInfo.video_height);
        params.setAudioCoding(mStreamInfo.audio_coding);
        params.setAudioNumChannels(mStreamInfo.audio_num_channels);
        params.setAudioSamplingFreq(mStreamInfo.audio_sampling_freq);
        // download params
        params.setInputFile(mDownloadInfo.url + ",0,-1;");
        params.setInputMime("ts");
        params.setOutputFormat("mp4");
//        params.setPosterData(downloadOptions.clipDownloadInfo.posterData);
        params.setGpsData(null);
        params.setAccData(null);
        params.setObdData(null);
        params.setAudioFormat("mp3");
        // add to queue
        //   RemuxHelper.remux(this, params);
        startDownloadVideo(outputFile, params, subscriber);
    }

    private void startDownloadVideo(String outputFile, RemuxerParams params, final ObservableEmitter<? super Integer> subscriber) {
        Logger.t(TAG).d("start download item " + params.getInputFile());

        remuxer.setEventListener((remuxer, event, arg1, arg2) -> {
            Logger.t(TAG).d("Event: " + event + " arg1: " + arg1 + " arg2: " + arg2);
            if (Thread.interrupted())
                if (subscriber == null) {
                    return;
                }
            switch (event) {
                case HttpRemuxer.EVENT_ERROR:
                    subscriber.onError(new Throwable("download error"));
                    break;
                case HttpRemuxer.EVENT_PROGRESS:
                    subscriber.onNext(arg1);
                    break;
                case HttpRemuxer.EVENT_FINISHED:
                    Logger.t(TAG).d("Event: " + event + " arg1: " + arg1 + " arg2: " + arg2);
                    subscriber.onComplete();
                    break;
            }
        });

        Logger.t(TAG).d("outputFile: " + outputFile);
        if (outputFile == null) {
            Logger.t(TAG).e("Output File is null");
        } else {
            remuxer.run(params, outputFile);
            Logger.t(TAG).d("remux is running output file is: " + outputFile);
        }
    }

}
