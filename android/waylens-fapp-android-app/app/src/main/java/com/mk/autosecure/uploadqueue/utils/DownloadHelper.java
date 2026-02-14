package com.mk.autosecure.uploadqueue.utils;

import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import com.mkgroup.camera.preference.PreferenceUtils;

import java.lang.ref.WeakReference;

/**
 * Created by Richard on 2/2/16.
 */
public class DownloadHelper {

    private static final String TAG = "DownloadHelper";
    public static final String DOWNLOAD_ID = "DownloadHelper_id";

    DownloadManager downloadManager = null;

    WeakReference<Context> mContextReference;

    OnDownloadListener mDownloadListener;

    IDownloadable mDownloadable;

    public DownloadHelper(Context context, OnDownloadListener listener) {
        mContextReference = new WeakReference<Context>(context);
        downloadManager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
        mDownloadListener = listener;
    }

    public void download(IDownloadable downloadable) {
        if (downloadManager == null || mContextReference == null || mContextReference.get() == null) {
            return;
        }
        mDownloadable = downloadable;
        DownloadManager.Request request;
        try {
            request = downloadable.getDownloadRequest(mContextReference.get());
            if (request != null) {
                long downloadID = downloadManager.enqueue(request);
                PreferenceUtils.putLong(DOWNLOAD_ID, downloadID);
            }
        } catch (Exception e) {
            Log.e(TAG, "", e);
            if (mDownloadListener != null) {
                mDownloadListener.onError(downloadable);
            }
        }
    }

    public void clearListener() {
        mDownloadListener = null;
    }

    void queryDownloadStatus() {
        DownloadManager.Query query = new DownloadManager.Query();
        long downloadId = PreferenceUtils.getLong(DOWNLOAD_ID, 0);
        query.setFilterById(downloadId);
        Cursor c = downloadManager.query(query);
        if (c.moveToFirst()) {
            int status = c.getInt(c.getColumnIndex(DownloadManager.COLUMN_STATUS));
            switch (status) {
                case DownloadManager.STATUS_PAUSED:
                    log("STATUS_PAUSED");
                case DownloadManager.STATUS_PENDING:
                    log("STATUS_PENDING");
                case DownloadManager.STATUS_RUNNING:
                    log("STATUS_RUNNING");
                    break;
                case DownloadManager.STATUS_SUCCESSFUL:
                    log("File is downloaded.");

                    String downloadedFile = null;
                    if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M) {
                        int fileUriIdx = c.getColumnIndex(DownloadManager.COLUMN_LOCAL_URI);
                        String fileUri = c.getString(fileUriIdx);
                        if (fileUri != null) {
                            downloadedFile = Uri.parse(fileUri).getPath();
                        }
                    } else {
                        //Android 7.0以上的方式：请求获取写入权限，这一步报错
                        //过时的方式：DownloadManager.COLUMN_LOCAL_FILENAME
                        int fileNameIdx = c.getColumnIndex(DownloadManager.COLUMN_LOCAL_FILENAME);
                        downloadedFile = c.getString(fileNameIdx);
                    }

                    PreferenceUtils.remove(DOWNLOAD_ID);
                    if (mDownloadListener != null && mDownloadable != null) {
                        mDownloadListener.onSuccess(mDownloadable, downloadedFile);
                    }
                    break;
                case DownloadManager.STATUS_FAILED:
                    log("STATUS_FAILED");
                    downloadManager.remove(downloadId);
                    PreferenceUtils.remove(DOWNLOAD_ID);
                    if (mDownloadListener != null) {
                        mDownloadListener.onError(mDownloadable);
                    }
                    break;
            }
        }
    }

    void log(String msg) {
        Log.e(TAG, msg);
    }

    public final BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            queryDownloadStatus();
        }
    };

    public interface IDownloadable {
        DownloadManager.Request getDownloadRequest(Context context);
    }

    public interface OnDownloadListener {
        void onSuccess(IDownloadable downloadable, String filePath);

        void onError(IDownloadable downloadable);
    }
}
