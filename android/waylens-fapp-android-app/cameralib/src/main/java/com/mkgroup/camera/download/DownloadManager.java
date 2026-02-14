package com.mkgroup.camera.download;

import com.mkgroup.camera.rest.Optional;
import com.orhanobut.logger.Logger;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Future;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.schedulers.Schedulers;
import io.reactivex.subjects.BehaviorSubject;


/**
 * Created by DoanVT on 2017/12/22.
 * Email: doanvt-hn@mk.com.vn
 */
public class DownloadManager {
    private static final String TAG = DownloadManager.class.getSimpleName();

    private List<DownloadJob> mDownloadQueue = null;
    private Map<String, Future<Integer>> mDownloadFutureMap = null;
    private ThreadPoolExecutor mExecutor;

    private BehaviorSubject<Optional<ExportEvent>> exportableJob = BehaviorSubject.create();

    private BehaviorSubject<Boolean> mRunning = BehaviorSubject.create();

    private int currentJobIndex = -1;

    private volatile static DownloadManager mSharedUploadManager = null;

    private DownloadJobListener mDownloadListener;

    private DownloadJob pausedJob;

    private DownloadManager() {
        mDownloadQueue = new ArrayList<>();
        mDownloadFutureMap = new HashMap<>();
        mExecutor = new ThreadPoolExecutor(1, 1, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());
        mDownloadListener = new DownloadJobListener() {
            @Override
            public void onComplete(String key) {
                DownloadJob job = getItem(key);
                if (job != null) {
                    job.setTerminated(true);
                }
                currentJobIndex = -1;

                DownloadJob nextJob = getNextPendingJob();
                Logger.t(TAG).d("next job = " + nextJob + " pausedJob: " + pausedJob);
                if (nextJob != null) {
                    submitJob(nextJob);
                } else if (pausedJob != null) {
                    submitJob(pausedJob);
                    pausedJob = null;
                } else {
                    mRunning.onNext(false);
                    exportableJob.onNext(Optional.empty());
                    mDownloadQueue.clear();
                    currentJobIndex = -1;
                }
            }

            @Override
            public void onError(String key) {

            }
        };
    }

    public static DownloadManager getManager() {
        if (mSharedUploadManager == null) {
            synchronized (DownloadManager.class) {
                if (mSharedUploadManager == null) {
                    mSharedUploadManager = new DownloadManager();
                }
            }
        }
        return mSharedUploadManager;
    }

    public BehaviorSubject<Optional<ExportEvent>> exportJobEvent() {
        return this.exportableJob;
    }

    public Observable<Boolean> isRunning() {
        return mRunning;
    }

    public void addJob(DownloadJob job) {
        job.setDownloadJobListener(mDownloadListener);
        mDownloadQueue.add(job);
        if (mExecutor.getActiveCount() < 1) {
            submitJob(job);
        }
    }

    private void submitJob(DownloadJob job) {
        if (!mRunning.hasValue()) {
            mRunning.onNext(true);
        }
        Future<Integer> future = mExecutor.submit(job);
        mDownloadFutureMap.put(job.getKey(), future);
        currentJobIndex = getItemPosition(job.getKey());
    }

    private DownloadJob getItem(String key) {
        for (DownloadJob job : mDownloadQueue) {
            if (job.getKey().equals(key)) {
                return job;
            }
        }
        return null;
    }

    public int getJobCount() {
        return mDownloadQueue.size();
    }

    public DownloadJob getNextPendingJob() {
        for (DownloadJob job : mDownloadQueue) {
            if (!job.isTerminated()) {
                return job;
            }
        }
        return null;
    }

    public void cancelCurrentJob(boolean pause) {
        if (currentJobIndex >= 0 && currentJobIndex < mDownloadQueue.size()) {
            try {
                DownloadJob job = mDownloadQueue.get(currentJobIndex);
                if (pause) pausedJob = job;
                job.mDownloadProgress = 0;
                Future<Integer> future = mDownloadFutureMap.get(job.getKey());
                Observable.create((ObservableOnSubscribe<Void>) emitter ->
                {
                    if (future != null) {
                        future.cancel(true);
                    }
                })
                        .subscribeOn(Schedulers.io())
                        .subscribe();
            } catch (Exception ex) {
                Logger.t(TAG).d("cancelCurrentJob error = " + ex.getMessage());
            }
        }
    }

    public int getItemPosition(String key) {
        for (int i = 0; i < mDownloadQueue.size(); i++) {
            DownloadJob job = mDownloadQueue.get(i);
            if (job.getKey().equals(key)) {
                return i;
            }
        }
        return -1;
    }

}