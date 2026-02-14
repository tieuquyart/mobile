package com.mk.autosecure.viewmodels;

import android.content.Context;
import android.text.TextUtils;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.libs.ActivityViewModel;
import com.mk.autosecure.ui.activity.ExportActivity;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.download.DownloadJob;
import com.mkgroup.camera.download.DownloadManager;
import com.mkgroup.camera.download.ExportEvent;
import com.mkgroup.camera.download.ExportableJob;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.rest.Optional;
import com.mk.autosecure.libs.account.CurrentUser;

import io.reactivex.Observable;


/**
 * Created by DoanVT on 2018/1/24.
 * Email: doanvt-hn@mk.com.vn
 */

public interface ExportActivityViewModel {

    interface Inputs {
        void currentCamera(CameraWrapper camera);

        void exportAngle(int angle);

        void exportMode(boolean fullScreen);

        void exportStream(int stream);

        void enableTime(boolean enableTime);

        void download(Clip clip, int duration, long offset);

        void download(String url, long createTime, int duration, String rotate, int type, String location, boolean needDewarp);
    }

    interface Outputs {
        Observable<Optional<ExportEvent>> exportJobEvent();
    }

    final class ViewModel extends ActivityViewModel<ExportActivity> implements Inputs, Outputs {
        public static final String TAG = ViewModel.class.getSimpleName();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            appContext = appComponent.appContext();
        }

        private CurrentUser currentUser;
        private final Context appContext;

        private CameraWrapper mCamera;

        public final Inputs inputs = this;
        public final Outputs outputs = this;

        private int angle;
        private boolean fullScreen;
        private int stream;
        private boolean enableTime;

        private boolean transcode = false;

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        public void setTranscode(boolean transcode) {
            this.transcode = transcode;
        }

        @Override
        public void exportAngle(int angle) {
            this.angle = angle;
        }

        @Override
        public void exportMode(boolean mode) {
            this.fullScreen = mode;
        }

        @Override
        public void exportStream(int stream) {
            this.stream = stream;
        }

        @Override
        public void enableTime(boolean enableTime) {
            this.enableTime = enableTime;
        }

        @Override
        public void currentCamera(CameraWrapper vdtCamera) {
            mCamera = vdtCamera;
        }


        /**
         * tải clip
         */
        @Override
        public void download(Clip oneClip, int duration, long offset) {
            Logger.t(ViewModel.class.getSimpleName()).d("mCamera == " + mCamera);
            if (oneClip == null || mCamera == null) {
                return;
            }
            Clip clip = mCamera.getClipsManager().getAccurateClip(oneClip);
            Logger.t(this.getClass().getSimpleName()).d("clip duration != %d", clip.getDurationMs());

            Logger.t(TAG).e("getJobCount: " + DownloadManager.getManager().getJobCount());
            if (DownloadManager.getManager().getJobCount() != 0) {
                DownloadManager.getManager().cancelCurrentJob(true);
            }

            DownloadJob job = new DownloadJob(appContext, duration, offset, clip, clip.streams[stream], stream);
            job.setAngle(angle);
            job.setFullScreen(fullScreen);
            job.setEnableTime(enableTime);
            job.setTranscode(transcode);
            job.setExportEventTag(ExportActivity.TAG);
            job.setOnProgressChangedListener(new ExportableJob.OnProgressChangedListener() {
                @Override
                public void OnProgressChanged(ExportEvent event) {
                    DownloadManager.getManager().exportJobEvent().onNext(Optional.ofNullable(event));
                }

                @Override
                public void OnFinished(ExportEvent event) {
                    DownloadManager.getManager().exportJobEvent().onNext(Optional.ofNullable(event));
                }

                @Override
                public void OnDownloadInfo(ExportEvent event) {
                    DownloadManager.getManager().exportJobEvent().onNext(Optional.ofNullable(event));
                }

                @Override
                public void OnError(ExportEvent event) {
                    DownloadManager.getManager().exportJobEvent().onNext(Optional.ofNullable(event));
                }
            });
            DownloadManager.getManager().addJob(job);
        }


        /**
         * tải clip theo url
         */
        @Override
        public void download(String url, long createTime, int duration, String rotate, int type, String location, boolean needDewarp) {
            if (TextUtils.isEmpty(url)) {
                return;
            }

            Logger.t(TAG).e("getJobCount: " + DownloadManager.getManager().getJobCount());
            if (DownloadManager.getManager().getJobCount() != 0) {
                DownloadManager.getManager().cancelCurrentJob(true);
            }

            DownloadJob job = new DownloadJob(appContext, url, createTime, duration, rotate, type, location, needDewarp);
            job.setAngle(angle);
            job.setFullScreen(fullScreen);
            job.setEnableTime(enableTime);
            job.setTranscode(transcode);
            job.setExportEventTag(ExportActivity.TAG);
            job.setOnProgressChangedListener(new ExportableJob.OnProgressChangedListener() {
                @Override
                public void OnProgressChanged(ExportEvent event) {
                    DownloadManager.getManager().exportJobEvent().onNext(Optional.ofNullable(event));
                }

                @Override
                public void OnFinished(ExportEvent event) {
                    DownloadManager.getManager().exportJobEvent().onNext(Optional.ofNullable(event));
                }

                @Override
                public void OnDownloadInfo(ExportEvent event) {
                    DownloadManager.getManager().exportJobEvent().onNext(Optional.ofNullable(event));
                }

                @Override
                public void OnError(ExportEvent event) {
                    DownloadManager.getManager().exportJobEvent().onNext(Optional.ofNullable(event));
                }
            });
            DownloadManager.getManager().addJob(job);
        }

        /**
         * export event
         * */
        public Observable<Optional<ExportEvent>> exportJobEvent() {
            return DownloadManager.getManager().exportJobEvent();
        }
    }
}
