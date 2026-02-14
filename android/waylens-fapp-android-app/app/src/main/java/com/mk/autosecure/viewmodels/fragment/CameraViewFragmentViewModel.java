package com.mk.autosecure.viewmodels.fragment;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.text.TextUtils;
import android.view.WindowManager;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.mk.autosecure.AppComponent;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.libs.GPUImage.TwoDirectionTransform;
import com.mk.autosecure.model.ClipPosChangeEvent;
import com.mk.autosecure.ui.fragment.CameraViewFragment;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.constant.VideoStreamType;
import com.mkgroup.camera.download.DownloadJob;
import com.mkgroup.camera.download.DownloadManager;
import com.mkgroup.camera.download.ExportEvent;
import com.mkgroup.camera.download.ExportableJob;
import com.mkgroup.camera.glide_adapter.SnipeGlideLoader;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipPos;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.utils.RxBus;
import com.mk.autosecure.libs.account.CurrentUser;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

public interface CameraViewFragmentViewModel {

    interface Inputs {
        void updateLiveTime(long absTime /* in millis*/);

        void isLiveOrNot(boolean isLive);

        void pollVideoProgress();

        void playOrPause(boolean state);

        void clipPosChanged(ClipPos clipPos);

        void fetchThumbnail(String thumbnailUrl);

        void fetchThumbnail(ClipPos clipPos);

        void filterClip(List<Clip> clipList, List<String> filterList);

        void filterClipBean(Map<String, Integer> clipListStat, List<String> filterList);

        void filterVisibility(int visibility);

        void download(Clip clip, int duration, long offset);

        void inputStreamIndex(int index);

        void inputStreamType(VideoStreamType streamType);
    }

    interface Outputs {
        Observable<Integer> videoType();

        Observable<Long> liveTime();

        Observable<Optional<Void>> videoProgress();

        Observable<Boolean> playerControl();

        Observable<ClipPos> clipPosChanged();

        Observable<Optional<Bitmap>> getThumbnail();

        Observable<List<Clip>> loadClips();

        Observable<Integer> loadClipBeans();

        Observable<Integer> filterVisibility();

        Observable<Optional<ExportEvent>> exportJobEvent();
    }

    interface Errors {

    }

    final class ViewModel extends FragmentViewModel<CameraViewFragment> implements Inputs, Outputs, Errors {

        private volatile boolean lockRequest = false;

        private volatile ClipPos mLastClipPos;

        @SuppressLint("CheckResult")
        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            currentUser = appComponent.currentUser();
            mContext = appComponent.appContext();
            videoType.onNext(0);

            RxBus.getDefault().toObservable(ClipPosChangeEvent.class)
                    .observeOn(Schedulers.newThread())
                    .compose(bindToLifecycle())
                    .filter(clipPosChangeEvent -> clipPosChangeEvent.getPublisher().equals(TAG))
                    .subscribe(clipPosChangeEvent -> {
                        if (lockRequest) {
                            mLastClipPos = clipPosChangeEvent.getClipPos();
                        } else {
                            lockRequest = true;
                            requestBitmap(clipPosChangeEvent.getClipPos());
                        }
                    });
        }

        /**
         * lấy thông tin bitmap
         * */
        @SuppressLint("CheckResult")
        private void requestBitmap(ClipPos clipPos) {
            Observable.create((ObservableOnSubscribe<Optional>) emitter -> {
                WindowManager manager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
                if (manager != null) {
                    int width = manager.getDefaultDisplay().getWidth();
                    if (clipPos != null) {
//                        Logger.t(TAG).e("实际请求: " + clipPos.getClipId().subType
//                                + " " + clipPos.getClipTimeMs());
                        Bitmap bitmap = null;
                        try {
                            bitmap = Glide.with(mContext)
                                    .using(new SnipeGlideLoader(VdtCameraManager.getManager().getCurrentVdbRequestQueue(), true))
                                    .load(clipPos)
                                    .asBitmap()
                                    .transform(new TwoDirectionTransform(mContext, clipPos.clip.isLensNormal()))
                                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                                    .into(width, width * 9 / 16)
                                    .get();
                        } catch (ExecutionException | InterruptedException e) {
                            Logger.t(TAG).d("fetchThumbnail: " + e.getMessage());
                        }
                        getThumbnail.onNext(Optional.ofNullable(bitmap));
                    }
                }
                emitter.onNext(Optional.empty());
            })
                    .subscribeOn(Schedulers.newThread())
                    .compose(bindToLifecycle())
                    .subscribe(optional -> {
                        if (mLastClipPos != null) {
                            ClipPos lastClipPos = mLastClipPos;
                            mLastClipPos = null;
//                            Logger.t(TAG).d("处理请求结束, 但继续请求最后一个数据");
                            requestBitmap(lastClipPos);
                        } else {
//                            Logger.t(TAG).d("处理请求结束");
                            lockRequest = false;
                        }
                    });
        }

        private final String TAG = ViewModel.class.getSimpleName();

        private final BehaviorSubject<Integer> videoType = BehaviorSubject.create();

        private final BehaviorSubject<Long> liveTime = BehaviorSubject.create();

        private final BehaviorSubject<Optional<Void>> videoProgress = BehaviorSubject.create();

        private final PublishSubject<Boolean> playerControl = PublishSubject.create();

        private final PublishSubject<ClipPos> clipPosPublishSubject = PublishSubject.create();

        private final PublishSubject<Optional<Bitmap>> getThumbnail = PublishSubject.create();

        private final BehaviorSubject<List<Clip>> loadClips = BehaviorSubject.create();

        private final BehaviorSubject<Integer> loadClipBeans = BehaviorSubject.create();

        private final BehaviorSubject<Integer> filterVisibility = BehaviorSubject.create();

        public final Inputs inputs = this;

        public final Outputs outputs = this;

        private final CurrentUser currentUser;
        private final Context mContext;

        public volatile boolean isLiveOrNot = true;

        public volatile int mStreamIndex = 0;

        public volatile VideoStreamType mStreamType = VideoStreamType.Panorama;

        public List<String> filterList = new ArrayList<>();

        private Clip downloadClip;

        public CurrentUser getCurrentUser() {
            return currentUser;
        }

        @Override
        public void updateLiveTime(long absTime) {
            liveTime.onNext(absTime);
        }

        @Override
        public void isLiveOrNot(boolean isLive) {
            this.isLiveOrNot = isLive;
        }

        @Override
        public void pollVideoProgress() {
            Observable.interval(0, 500, TimeUnit.MILLISECONDS)
                    .subscribeOn(Schedulers.io())
                    .compose(bindToLifecycle())
                    .subscribe(aLong -> videoProgress.onNext(Optional.empty()),
                            throwable -> {
                                //这里在每次播放到最顶端时候 会报错null  原因不明 目前重新拉起
                                Logger.t(TAG).e("checkProgress throwable: " + throwable.getMessage());
                                pollVideoProgress();
                            });
        }

        @Override
        public Observable<Integer> videoType() {
            return this.videoType;
        }

        @Override
        public Observable<Long> liveTime() {
            return liveTime;
        }

        @Override
        public Observable<Optional<Void>> videoProgress() {
            return videoProgress;
        }

        @Override
        public Observable<Boolean> playerControl() {
            return playerControl;
        }

        @Override
        public Observable<ClipPos> clipPosChanged() {
            return clipPosPublishSubject;
        }

        @Override
        public Observable<Optional<Bitmap>> getThumbnail() {
            return getThumbnail;
        }

        @Override
        public Observable<List<Clip>> loadClips() {
            return loadClips;
        }

        @Override
        public Observable<Integer> loadClipBeans() {
            return loadClipBeans;
        }

        @Override
        public Observable<Integer> filterVisibility() {
            return filterVisibility;
        }

        @Override
        public Observable<Optional<ExportEvent>> exportJobEvent() {
            return DownloadManager.getManager().exportJobEvent();
        }

        @Override
        public void playOrPause(boolean state) {
            playerControl.onNext(state);
        }

        @Override
        public void clipPosChanged(ClipPos clipPos) {
            clipPosPublishSubject.onNext(clipPos);
        }

        @Override
        public void fetchThumbnail(String thumbnailUrl) {
            WindowManager manager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
            if (manager != null) {
                int width = manager.getDefaultDisplay().getWidth();
                Observable.create((ObservableOnSubscribe<Optional<Bitmap>>) emitter -> {
                    try {
                        if (!TextUtils.isEmpty(thumbnailUrl)) {
                            Bitmap bitmap = Glide.with(mContext)
                                    .load(thumbnailUrl)
                                    .asBitmap()
                                    .diskCacheStrategy(DiskCacheStrategy.ALL)
                                    .into(width, width * 9 / 16)
                                    .get();
                            getThumbnail.onNext(Optional.ofNullable(bitmap));
                        }
                    } catch (Exception ex) {
                        Logger.t(TAG).d("fetchThumbnail: " + ex.getMessage());
                    }
                })
                        .subscribeOn(Schedulers.io())
                        .compose(bindToLifecycle())
                        .subscribe();
            }
        }

        @Override
        public void fetchThumbnail(ClipPos clipPos) {
            RxBus.getDefault().post(new ClipPosChangeEvent(clipPos, TAG));
        }

        @Override
        public void filterClip(List<Clip> clipList, List<String> filterList) {
            this.filterList = filterList;
            if (filterList.size() == 0) {
                loadClips.onNext(clipList);
            } else {
                List<Integer> list = VideoEventType.getIntTypeFilterList(mContext, filterList);

                List<Clip> tempList = new ArrayList<>();

                int length = list.size();
                for (int i = 0; i < length; i++) {
                    for (Clip clip : clipList) {
                        if (clip.videoType == list.get(i)) {
                            tempList.add(clip);
                        }
                    }
                }
                loadClips.onNext(tempList);
            }
        }

        @Override
        public void filterClipBean(Map<String, Integer> clipListStat, List<String> filterList) {
            this.filterList = filterList;
            if (filterList.size() == 0) {
                int count = 0;
                for (Integer integer : clipListStat.values()) {
                    count += integer;
                }
                loadClipBeans.onNext(count);
            } else {
                List<String> list = VideoEventType.getStringTypeFilterList(mContext, filterList);

                int count = 0;

                int length = list.size();
                for (int i = 0; i < length; i++) {
                    for (Map.Entry<String, Integer> next : clipListStat.entrySet()) {
                        if (list.get(i).equals(next.getKey())) {
                            count += next.getValue();
                        }
                    }
                }
                loadClipBeans.onNext(count);
            }
        }

        @Override
        public void filterVisibility(int visibility) {
            filterVisibility.onNext(visibility);
        }

        public Clip getDownloadClip() {
            return downloadClip;
        }

        public void setDownloadClip(Clip downloadClip) {
            this.downloadClip = downloadClip;
        }

        @Override
        public void download(Clip oneClip, int duration, long offset) {
            CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
            Logger.t(TAG).d("mCamera == " + camera);
            if (oneClip == null || camera == null) {
                return;
            }
            Clip clip = camera.getClipsManager().getAccurateClip(oneClip);
            Logger.t(this.getClass().getSimpleName()).d("clip duration != %d", clip.getDurationMs());

            Logger.t(TAG).e("getJobCount: " + DownloadManager.getManager().getJobCount());
            if (DownloadManager.getManager().getJobCount() != 0) {
                DownloadManager.getManager().cancelCurrentJob(true);
            }

            DownloadJob job = new DownloadJob(mContext, duration, offset, clip, clip.streams[mStreamIndex], mStreamIndex);
            job.setTranscode(false);
//            job.setAngle(angle);
//            job.setFullScreen(fullScreen);
//            job.setEnableTime(enableTime);
            job.setExportEventTag(CameraViewFragment.TAG);
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

        @Override
        public void inputStreamIndex(int index) {
            this.mStreamIndex = index;
        }

        @Override
        public void inputStreamType(VideoStreamType streamType) {
            this.mStreamType = streamType;
        }
    }
}
