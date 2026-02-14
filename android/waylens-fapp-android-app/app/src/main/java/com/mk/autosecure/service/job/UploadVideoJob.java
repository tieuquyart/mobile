package com.mk.autosecure.service.job;

import com.mk.autosecure.libs.utils.HashUtils;
import com.mk.autosecure.libs.utils.Hex;
import com.mk.autosecure.libs.utils.StringUtils;
import com.mk.autosecure.rest.ApiService;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.service.upload.UploadAPI;
import com.mk.autosecure.service.upload.UploadProgressRequestBody;
import com.mk.autosecure.uploadqueue.body.CreateMomentBody;
import com.mk.autosecure.uploadqueue.entities.LocalMoment;
import com.mk.autosecure.uploadqueue.entities.UploadServer;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Locale;

import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;
import okhttp3.MediaType;
import okhttp3.RequestBody;

public class UploadVideoJob implements Runnable {

    private static final String TAG = UploadVideoJob.class.getSimpleName();

    private LocalMoment localMoment;
    private int mUploadProgress;
    private boolean mStopUploading;
    private Disposable mDisposable;

    public UploadVideoJob(LocalMoment localMoment) {
        this.localMoment = localMoment;
    }

    public void cancel() {
        mStopUploading = true;
    }

    @Override
    public void run() {
        CreateMomentBody createMomentBody = new CreateMomentBody(localMoment);

        ApiService.createApiService().createMoment(createMomentBody)
                .subscribeOn(Schedulers.io())
                .observeOn(Schedulers.io())
                .subscribe(response -> {
                    UploadServer uploadServer = response.uploadServer;
                    if (uploadServer == null) {
                        Logger.t(TAG).e("upload server is empty");
                        RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_ERROR));
                        return;
                    }
                    Logger.t(TAG).d("upload server: " + uploadServer.toString());
                    RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_START));
                    mUploadProgress = 0;

                    try {
                        String fileSha1 = Hex.encodeHexString(HashUtils.encodeSHA1(new File(localMoment.rawPath)));

                        SimpleDateFormat format = new SimpleDateFormat("EEE, dd MMM yyy hh:mm:ss", Locale.US);
                        String date = format.format(System.currentTimeMillis()) + " GMT";
                        String server = StringUtils.getHostNameWithoutPrefix(uploadServer.url);

                        String authorization = AuthorizationHelper.getAuthorization(server,
                                localMoment.userID + "/android",
                                response.momentID,
                                fileSha1,
                                "upload_resource",
                                date,
                                uploadServer.privateKey);

//                        checkIfStopped();
                        UploadAPI uploadAPI = new UploadAPI(uploadServer.url + "/", date, authorization, -1);

                        RequestBody requestBody = RequestBody.create(MediaType.parse("video/mpeg4"), new File(localMoment.rawPath));

                        UploadProgressRequestBody progressRequestBody = new UploadProgressRequestBody(requestBody, (bytesWritten, contentLength, done) -> {
                            int progress = (int) ((bytesWritten * 100) / contentLength);
                            if (Math.abs(progress - mUploadProgress) >= 2) {
                                try {
                                    checkIfStopped();
                                    mUploadProgress = progress;
                                    Logger.t(TAG).d("mUploadProgress: " + progress);
                                    RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_PROGRESS, progress));
                                } catch (InterruptedException e) {
                                    releaseUpload();
                                }
                            }
                        });

                        //access_level: public; protect; private. resolution: 1 1080p; 2 720p; 4 480p; 8 360p only used in mp4
                        uploadAPI.uploadMp4Sync(progressRequestBody, localMoment.userID, response.momentID, fileSha1, 8, localMoment.duration)
                                .subscribeOn(Schedulers.io())
                                .subscribe(new Observer<UploadDataResponse>() {
                                    @Override
                                    public void onSubscribe(Disposable d) {
                                        mDisposable = d;
                                    }

                                    @Override
                                    public void onNext(UploadDataResponse uploadMp4Sync) {
                                        Logger.t(TAG).d("uploadMp4Sync: " + uploadMp4Sync);

                                        if (uploadMp4Sync != null && uploadMp4Sync.result == 2) {
                                            RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_FINISHED));
                                        } else {
                                            RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_ERROR));
                                        }
                                    }

                                    @Override
                                    public void onError(Throwable e) {
                                        Logger.t(TAG).e("uploadMp4Sync onError: " + e.getMessage());
                                        RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_ERROR));
                                        releaseUpload();
                                    }

                                    @Override
                                    public void onComplete() {
                                        releaseUpload();
                                    }
                                });
                    } catch (Exception ex) {
                        Logger.t(TAG).e("exception: " + ex.getMessage());
//                        RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_ERROR));
                    }
                }, throwable -> {
                    Logger.t(TAG).e("createMoment throwable: " + throwable.getMessage());
                    RxBus.getDefault().post(new UploadDataEvent(UploadDataEvent.Status.UPLOAD_WHAT_ERROR));
                });
    }

    private void releaseUpload() {
        if (mDisposable != null && !mDisposable.isDisposed()) {
            mDisposable.dispose();
        }
    }

    private void checkIfStopped() throws InterruptedException {
        if (mStopUploading) {
            throw new InterruptedException();
        }
    }

}
