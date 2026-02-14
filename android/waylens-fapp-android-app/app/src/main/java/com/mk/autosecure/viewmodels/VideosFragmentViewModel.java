package com.mk.autosecure.viewmodels;


import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;

import com.mk.autosecure.AppComponent;
import com.mk.autosecure.constant.VideoEventType;
import com.mk.autosecure.libs.FragmentViewModel;
import com.mk.autosecure.rest.ServerErrorHandler;
import com.mk.autosecure.ui.data.IntentKey;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.CameraWrapper;
import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.data.vdb.BasicVdbSocket;
import com.mkgroup.camera.data.vdb.VdbRequestFuture;
import com.mkgroup.camera.data.vdb.VdbRequestQueue;
import com.mkgroup.camera.download.DownloadManager;
import com.mkgroup.camera.download.ExportEvent;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipSet;
import com.mkgroup.camera.rest.Optional;
import com.mkgroup.camera.toolbox.ClipSetExRequest;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mk.autosecure.ui.fragment.VideosFragment;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;


/**
 * Created by DoanVT on 2017/7/25.
 */

public interface VideosFragmentViewModel {

    interface Inputs {

        /**
         * Call when the clip is clicked.
         **/
        void videoClicked(int videoId);

        void filterVisibility(int visibility);

        void filterResource(int resource);

        void currentCamera(CameraWrapper camera);

        Observable<Integer> deleteClip(Clip clip);

        void loadClips(List<String> filterList, boolean useCache);
    }

    interface Outputs {

        Observable<Integer> videoType();

        Observable<Integer> filterVisibility();

        Observable<Integer> filterShow();

        Observable<List<Clip>> clipList();
    }

    final class ViewModel extends FragmentViewModel<VideosFragment> implements Inputs, Outputs {

        private final static String TAG = ViewModel.class.getSimpleName();

        public ViewModel(AppComponent appComponent) {
            super(appComponent);
            videoType.onNext(0);
            mContext = appComponent.appContext();
            arguments()
                    .observeOn(Schedulers.io())
                    .subscribe(bundleOptional -> {
                        Bundle bundle = bundleOptional.getIncludeNull();
                        if (bundle != null) {
                            serialNumber = bundle.getString(IntentKey.SERIAL_NUMBER);
                        }
                    }, new ServerErrorHandler());

        }

        private String serialNumber;

        private final Context mContext;

        public CameraWrapper mCamera;

        private boolean mRetryLoadTag = true;

        private final BehaviorSubject<Integer> videoType = BehaviorSubject.create();

        private final BehaviorSubject<Integer> filterVisibility = BehaviorSubject.create();

        private final BehaviorSubject<Integer> filterShow = BehaviorSubject.create();

        private final BehaviorSubject<List<Clip>> clipList = BehaviorSubject.create();

        private final BehaviorSubject<ExportEvent> exportableJob = BehaviorSubject.create();

        public final VideosFragmentViewModel.Inputs inputs = this;
        public final VideosFragmentViewModel.Outputs outputs = this;

        @Override
        public void videoClicked(int videoId) {
            //
        }

        @Override
        public void filterVisibility(int visibility) {
            filterVisibility.onNext(visibility);
        }

        @Override
        public void filterResource(int resource) {
            filterShow.onNext(resource);
        }

        @Override
        public void currentCamera(CameraWrapper cameraWrapper) {
            mCamera = cameraWrapper;
        }

        /**
         * xóa clip
         */
        @Override
        public Observable<Integer> deleteClip(Clip clip) {
            return Observable.defer(() -> {
                try {
                    return Observable.just(SnipeApi.deleteClip(clip.cid));
                } catch (ExecutionException | InterruptedException e) {
                    return Observable.error(e);
                }
            });
        }

        /**
         * tải clip
         */
        @SuppressLint("CheckResult")
        @Override
        public void loadClips(List<String> filterList, boolean useCache) {
            Observable.create((ObservableOnSubscribe<List<Clip>>) emitter -> {
                        try {
                            if (useCache) {
                                filterClip(mCamera.getClipsManager().getClipList(), filterList);
                            } else {
                                Logger.t(TAG).d("load start");

                                List<Clip> newClipList = new ArrayList<>();

                                CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();

                                int flag = ClipSetExRequest.FLAG_CLIP_EXTRA | ClipSetExRequest.FLAG_CLIP_DESC
                                        | ClipSetExRequest.FLAG_CLIP_ATTR | ClipSetExRequest.FLAG_CLIP_SCENE_DATA
//                                | ClipSetExRequest.FLAG_CLIP_RAW_FCC | ClipSetExRequest.FLAG_CLIP_VIDEO_TYPE
                                        | ClipSetExRequest.FLAG_CLIP_VIDEO_DESCR;

                                boolean isVdtCamera = camera.getServerInfo().isVdtCamera;
                                if (!isVdtCamera) {
                                    flag = flag | ClipSetExRequest.FLAG_CLIP_RAW_FCC | ClipSetExRequest.FLAG_CLIP_VIDEO_TYPE;
                                }

                                VdbRequestFuture<ClipSet> futureMarked = VdbRequestFuture.newFuture();
                                ClipSetExRequest requestMarked = new ClipSetExRequest(Clip.TYPE_MARKED, flag, 0, futureMarked, futureMarked);
                                Logger.t(TAG).e("init args camera sn: " + camera.getSerialNumber() + " serialNumber: " + serialNumber);

                                if (TextUtils.isEmpty(serialNumber) || camera.getSerialNumber().equals(serialNumber)) {
                                    VdbRequestQueue requestQueue = camera.getRequestQueue();
                                    Logger.t(TAG).e("requestQueue exist: " + (requestQueue != null));
                                    if (requestQueue != null) {
                                        requestQueue.add(requestMarked);
                                        ClipSet clipSetMarked = futureMarked.get(5000, TimeUnit.MILLISECONDS);
                                        if (clipSetMarked != null) {
                                            Logger.t(TAG).e("TYPE_MARKED clipSet size: " + clipSetMarked.getCount());
                                            newClipList.addAll(clipSetMarked.getClipList());
                                        }
                                    } else {
                                        BasicVdbSocket vdbSocket = new BasicVdbSocket(camera.getVdbConnection());
                                        requestQueue = new VdbRequestQueue(vdbSocket);
                                        camera.setVdbRequestQueue(requestQueue);
                                    }
                                }

                                Logger.t(TAG).d("load half");

                                VdbRequestFuture<ClipSet> futureBuffered = VdbRequestFuture.newFuture();
                                ClipSetExRequest requestBuffered = new ClipSetExRequest(Clip.TYPE_BUFFERED, flag, 0, futureBuffered, futureBuffered);
                                Logger.t(TAG).e("init args");

                                if (TextUtils.isEmpty(serialNumber) || camera.getSerialNumber().equals(serialNumber)) {
                                    VdbRequestQueue requestQueue = camera.getRequestQueue();
                                    Logger.t(TAG).e("requestQueue exist: " + (requestQueue != null));
                                    if (requestQueue != null) {
                                        requestQueue.add(requestBuffered);
                                        ClipSet clipSetBuffered = futureBuffered.get(5000, TimeUnit.MILLISECONDS);
                                        if (clipSetBuffered != null) {
                                            Logger.t(TAG).e("TYPE_BUFFERED clipSet size: " + clipSetBuffered.getCount());
                                            newClipList.addAll(clipSetBuffered.getClipList());
                                        }
                                    } else {
                                        BasicVdbSocket vdbSocket = new BasicVdbSocket(camera.getVdbConnection());
                                        requestQueue = new VdbRequestQueue(vdbSocket);
                                        camera.setVdbRequestQueue(requestQueue);
                                    }
                                }

                                Logger.t(TAG).d("load all");

                                if (mCamera != null && mCamera.getClipsManager() != null) {
                                    mCamera.getClipsManager().refreshClipList(newClipList);
                                }

                                filterClip(newClipList, filterList);
                            }
                        } catch (Exception e) {
                            Logger.t(TAG).d("loadClips error " + e.getMessage() + " mRetryLoadTag: " + mRetryLoadTag);
                            if (mRetryLoadTag) {
                                mRetryLoadTag = false;

                                CameraWrapper camera = VdtCameraManager.getManager().getCurrentCamera();
                                if (camera == null) {
                                    Logger.t(TAG).e("camera == null");
                                } else {
                                    VdbRequestQueue requestQueue = camera.getRequestQueue();
                                    Logger.t(TAG).e("requestQueue exist: " + (requestQueue != null));
                                    if (requestQueue == null) {
                                        BasicVdbSocket vdbSocket = new BasicVdbSocket(camera.getVdbConnection());
                                        requestQueue = new VdbRequestQueue(vdbSocket);
                                        camera.setVdbRequestQueue(requestQueue);
                                    } else {
                                        requestQueue.start();
                                        loadClips(filterList, false);
                                    }
                                }
                            }
                        }
                    })
                    .subscribeOn(Schedulers.io())
                    .subscribe();
        }

        /**
         * lọc clip
         */
        private void filterClip(List<Clip> newClipList, List<String> filterList) {
            if (filterList.size() == 0) {
                clipList.onNext(newClipList);
            } else {
                List<Integer> list = VideoEventType.getIntTypeFilterList(mContext, filterList);

                List<Clip> tempList = new ArrayList<>();

                int length = list.size();
                for (int i = 0; i < length; i++) {
                    for (Clip clip : newClipList) {
                        if (clip.videoType == list.get(i)) {
                            tempList.add(clip);
                        }
                    }
                }
                clipList.onNext(tempList);
            }
        }

        @Override
        public Observable<Integer> videoType() {
            return this.videoType;
        }

        @Override
        public Observable<Integer> filterVisibility() {
            return filterVisibility;
        }

        @Override
        public Observable<Integer> filterShow() {
            return filterShow;
        }

        public Observable<List<Clip>> clipList() {
            return this.clipList;
        }

        public Observable<Optional<ExportEvent>> exportJobEvent() {
            return DownloadManager.getManager().exportJobEvent();
        }

    }
}
