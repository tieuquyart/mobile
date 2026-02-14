package com.mkgroup.camera.download;

import com.mkgroup.camera.db.VideoItem;
import com.mkgroup.camera.model.ClipDownloadInfo;
import com.mkgroup.camera.model.ClipPos;

import java.util.concurrent.Callable;

import static com.mkgroup.camera.download.ExportEvent.EVENT_TYPE_END;
import static com.mkgroup.camera.download.ExportEvent.EVENT_TYPE_INIT;
import static com.mkgroup.camera.download.ExportEvent.EVENT_TYPE_PROCESS;

/**
 * Created by DoanVT on 2017/9/28.
 */
public abstract class ExportableJob implements Callable<Integer> {

    private String key;

    protected String tag;

    protected boolean mIsFinished = false;

    private boolean mTerminated = false;

    protected int mDownloadProgress;

    protected ClipDownloadInfo.StreamDownloadInfo mDownloadInfo;

    protected String mOutputFile;
    protected OnProgressChangedListener mOnProgressChangedListener;

    protected ExportableJob() {
        this.key = String.valueOf(System.currentTimeMillis());
    }

    public String getKey() {
        return this.key;
    }

    public int getExportProgress() {
        return mDownloadProgress;
    }

    public ClipDownloadInfo.StreamDownloadInfo getDownloadInfo() {
        return mDownloadInfo;
    }

    public boolean isFinished() {
        return mIsFinished;
    }

    public boolean isTerminated() {
        return mTerminated;
    }

    public void setTerminated(boolean terminated) {
        this.mTerminated = terminated;
    }

    public String getOutputFile() {
        return mOutputFile;
    }

    public abstract ClipPos getClipStartPos();

    public void setOnProgressChangedListener(OnProgressChangedListener listener) {
        this.mOnProgressChangedListener = listener;
    }

    protected void notifyProgressChanged(int progress) {
        if (mDownloadProgress != progress) {
            mDownloadProgress = progress;
            if (mOnProgressChangedListener != null) {
                mOnProgressChangedListener.OnProgressChanged(new ExportEvent(tag, this, EVENT_TYPE_PROCESS));
            }
        }
    }

    protected void notifyFinished(VideoItem videoItem) {
        mIsFinished = true;
        if (mOnProgressChangedListener != null) {
            ExportEvent exportEvent = new ExportEvent(tag, this, EVENT_TYPE_END);
            exportEvent.setVideoItem(videoItem);
            mOnProgressChangedListener.OnFinished(exportEvent);
        }
    }

    protected void notifyDownloadInfo() {
        if (mOnProgressChangedListener != null) {
            mOnProgressChangedListener.OnDownloadInfo(new ExportEvent(tag, this, EVENT_TYPE_INIT));
        }
    }

    protected void notifyDownloadError() {
        if (mOnProgressChangedListener != null) {
            mOnProgressChangedListener.OnError(new ExportEvent(tag, this, EVENT_TYPE_END));
        }
    }

    public interface OnProgressChangedListener {
        void OnDownloadInfo(ExportEvent event);

        void OnProgressChanged(ExportEvent event);

        void OnFinished(ExportEvent event);

        void OnError(ExportEvent event);
    }
}

