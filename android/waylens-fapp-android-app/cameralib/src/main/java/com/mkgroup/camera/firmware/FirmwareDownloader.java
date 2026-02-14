package com.mkgroup.camera.firmware;

import com.mkgroup.camera.utils.FileUtils;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.network_adapter.OkHttpUrlLoader;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.Observer;
import io.reactivex.schedulers.Schedulers;
import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 * Created by DoanVT on 17/4/11.
 * Email: doanvt-hn@mk.com.vn
 */

public class FirmwareDownloader {
    private static final String TAG = FirmwareDownloader.class.getSimpleName();
    private HashMap<String, Call> downCalls;
    private DownLoadObserver mDownloadObserver;
    private OkHttpClient mClient;

    FirmwareDownloader(DownLoadObserver downLoadObserver) {
        this.downCalls = new HashMap<>();
        this.mDownloadObserver = downLoadObserver;
        this.mClient = OkHttpUrlLoader.Factory.getClient();
    }

    public void downLoad(String url) {
        if (downCalls.containsKey(url)) {
            return;
        }
        //这里推后，是因为国产机蜂窝数据回调较慢
//        this.mClient = OkHttpUrlLoader.Factory.getClient();
        DownloadInfo downloadInfo = createDownInfo(url);
        downloadInfo = checkDownloadInfo(downloadInfo);
        Observable.create(new DownloadSubscribe(downloadInfo))
                .subscribeOn(Schedulers.io())
                .subscribe(mDownloadObserver);
    }

    public boolean isDownloading(String url) {
        Call call = downCalls.get(url);
        return call != null;
    }


    public void cancel(String url) {
        Call call = downCalls.get(url);
        if (call != null) {
            call.cancel();
        }
        downCalls.remove(url);
    }

    public class DownloadSubscribe implements ObservableOnSubscribe<DownloadInfo> {
        private DownloadInfo downloadInfo;

        public DownloadSubscribe(DownloadInfo downloadInfo) {
            this.downloadInfo = downloadInfo;
        }

        @Override
        public void subscribe(ObservableEmitter<DownloadInfo> emitter) throws Exception {
            String url = downloadInfo.getUrl();
            long downloadLength = downloadInfo.getProgress();
            long contentLength = downloadInfo.getTotal();
            emitter.onNext(downloadInfo);

            Logger.t(TAG).i("downloadUrl: " + url);

            Request request = new Request.Builder()
                    .addHeader("RANGE", "bytes=" + downloadLength + "-" + contentLength)
                    .url(url)
                    .build();

            Call call = mClient.newCall(request);
            downCalls.put(url, call);
            InputStream is = null;
            FileOutputStream fileOutputStream = null;
            try {
                Response response = call.execute();
                File file = new File(FileUtils.getFirmwareDirectory(), downloadInfo.getFileName());
                is = response.body().byteStream();
                fileOutputStream = new FileOutputStream(file, true);
                byte[] buffer = new byte[128 * 1024];
                int len;
                while ((len = is.read(buffer)) != -1) {
                    fileOutputStream.write(buffer, 0, len);
                    downloadLength += len;
                    downloadInfo.setProgress(downloadLength);
                    emitter.onNext(downloadInfo);
                }
                fileOutputStream.flush();
                //subscriber.onCompleted();
                downloadInfo.setIsComplete(true);
                emitter.onNext(downloadInfo);
            } catch (IOException e) {
                Logger.t(TAG).e("DownloadSubscribe IOException: " + e.getMessage());
                e.printStackTrace();
                DownloadInfo tmp = new DownloadInfo(downloadInfo);
                tmp.setError(e);
                emitter.onNext(tmp);
            } finally {
                downCalls.remove(url);
                try {
                    if (is != null) {
                        is.close();
                    }
                    if (fileOutputStream != null) {
                        fileOutputStream.close();
                    }
                } catch (IOException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    public DownloadInfo createDownInfo(String url) {
        DownloadInfo downloadInfo = new DownloadInfo(url);
        long contentLength = getContentLength(url);
        downloadInfo.setTotal(contentLength);
        String fileName = url.substring(url.lastIndexOf("/"));
        downloadInfo.setFileName(fileName);
        return downloadInfo;
    }

    public DownloadInfo checkDownloadInfo(DownloadInfo downloadInfo) {
        String fileName = downloadInfo.getFileName();
        long downloadLength = 0, contentLength = downloadInfo.getTotal();
        File file = new File(FileUtils.getFirmwareDirectory(), fileName);
        if (file.exists()) {
            file.delete();
        }

        // 以下代码造成重复下载的问题
//        int i = 1;
//        while (downloadLength >= contentLength) {
//            int dotIndex = fileName.lastIndexOf(".");
//            String fileNameOther;
//            if (dotIndex == -1) {
//                fileNameOther = fileName + "(" + i + ")";
//            } else {
//                fileNameOther = fileName.substring(0, dotIndex)
//                        + "(" + i + ")" + fileName.substring(dotIndex);
//            }
//            File newFile = new File(FileUtils.getFirmwareDirectory(), fileNameOther);
//            file = newFile;
//            downloadLength = newFile.length();
//            i++;
//        }

        downloadInfo.setProgress(downloadLength);
        downloadInfo.setFileName(file.getName());
        return downloadInfo;
    }

    /**
     * @param
     * @return
     */
    private long getContentLength(String downloadUrl) {
        Request request = new Request.Builder()
                .url(downloadUrl)
                .build();
        try {
            Response response = mClient.newCall(request).execute();
            if (response != null && response.isSuccessful()) {
                long contentLength = response.body().contentLength();
                response.close();
                return contentLength == 0 ? DownloadInfo.TOTAL_ERROR : contentLength;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return DownloadInfo.TOTAL_ERROR;
    }

    public static class DownloadInfo {
        public static final long TOTAL_ERROR = -1;
        private boolean complete;
        private String url;
        private long total;
        private long progress;
        private String fileName;
        private Throwable error;

        public DownloadInfo(DownloadInfo downloadInfo) {
            this.url = downloadInfo.getUrl();
            this.total = downloadInfo.getTotal();
            this.progress = downloadInfo.getProgress();
            this.fileName = downloadInfo.getFileName();
            this.complete = downloadInfo.getIsComplete();
            this.error = downloadInfo.getError();
        }

        public DownloadInfo(String url) {
            this.url = url;
        }

        public String getUrl() {
            return url;
        }

        public String getFileName() {
            return fileName;
        }

        public void setFileName(String fileName) {
            this.fileName = fileName;
        }

        public long getTotal() {
            return total;
        }

        public void setTotal(long total) {
            this.total = total;
        }

        public long getProgress() {
            return progress;
        }

        public void setProgress(long progress) {
            this.progress = progress;
        }

        public boolean getIsComplete() {
            return complete;
        }

        public void setIsComplete(boolean complete) {
            this.complete = complete;
        }

        public Throwable getError() {
            return error;
        }

        public void setError(Throwable err) {
            error = err;
        }
    }

    public static abstract class DownLoadObserver implements Observer<DownloadInfo> {

        protected DownloadInfo downloadInfo;

        @Override
        public void onNext(DownloadInfo downloadInfo) {
            this.downloadInfo = downloadInfo;
        }

        @Override
        public void onError(Throwable e) {
            e.printStackTrace();
        }
    }
}
