package com.mkgroup.camera.download;

import android.content.ContentValues;
import android.content.Context;
import android.media.MediaScannerConnection;
import android.net.Network;
import android.net.Uri;
import android.os.Build;
import android.os.SystemClock;
import android.provider.MediaStore;
import android.text.TextUtils;

import androidx.annotation.RequiresApi;

import com.mkgroup.camera.WaylensCamera;
import com.mkgroup.camera.db.LocalVideoDaoManager;
import com.mkgroup.camera.db.VideoItem;
import com.mkgroup.camera.model.Clip;
import com.mkgroup.camera.model.ClipDownloadInfo;
import com.mkgroup.camera.model.ClipPos;
import com.mkgroup.camera.rest.NetworkService;
import com.mkgroup.camera.toolbox.DownloadUrlRequest;
import com.mkgroup.camera.toolbox.SnipeApi;
import com.mkgroup.camera.utils.CookieUtil;
import com.mkgroup.camera.utils.DateTime;
import com.mkgroup.camera.utils.FileUtils;
import com.mkgroup.camera.utils.NetworkUtils;
import com.mkgroup.camera.utils.ToStringUtils;
import com.orhanobut.logger.Logger;
//import com.waylens.camera.db.LocalVideoDaoManager;

import com.waylens.mediatranscoder.WLVideoDewarpParams;
import com.waylens.mediatranscoder.WLVideoTranscoder;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;
import java.util.concurrent.ExecutionException;

import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;

/**
 * Created by DoanVT on 2017/9/28.
 * Email: doanvt-hn@mk.com.vn
 */
public class DownloadJob extends ExportableJob {
    private static final String TAG = DownloadJob.class.getSimpleName();

    //clip params
    private int mStreamIndex;
    private int mDuration;
    private long mOffset;
    private Clip mClip;
    private Clip.StreamInfo mStreamInfo;

    private Disposable mDownloadSub;

    private Context context;

    private String url;

    private long createTime;

    private int type;

    private String location;

    private boolean needDewarp = true;

    private final transient Object mDownloadFence = new Object();

    private String mDownloadFilePath;

    private String mTmpOutputFile;

    private HttpURLConnection urlConnection;

    private DownloadJobListener mJobListener;

    private ClipDownloadHelper mDownloadHelper;

    private boolean downloadError = false;

    //fullScreen观看角度
    private int angle;

    //split screen or full screen
    private boolean fullScreen;

    //是否显示时间戳
    private boolean enableTime;

    //是否进行转码
    private boolean transcode = false;

    //当前是否正装
    private boolean mLensNormal = true;

    private WLVideoTranscoder mTranscoder;

    public DownloadJob(Context context, int duration, long offset, Clip clip, Clip.StreamInfo streamInfo, int streamIndex) {
        this.context = context;
        this.mDuration = duration;
        this.mOffset = offset;
        this.mClip = clip;
        this.mStreamInfo = streamInfo;
        this.mStreamIndex = streamIndex;
        this.mLensNormal = clip.isLensNormal();
        this.needDewarp = clip.getNeedDewarp();
    }

    public DownloadJob(Context context, String url, long createTime, int duration, String rotate, int type, String location, boolean needDewarp) {
        this.context = context;
        this.url = url;
        this.createTime = createTime;
        this.mDuration = duration;
        this.mLensNormal = TextUtils.isEmpty(rotate) || Clip.LENS_NORMAL.equals(rotate);
        this.type = type;
        this.location = location;
        this.needDewarp = needDewarp;
    }

    public void setAngle(int angle) {
        this.angle = angle;
    }

    public void setEnableTime(boolean enable) {
        this.enableTime = enable;
    }

    public void setFullScreen(boolean enable) {
        this.fullScreen = enable;
    }

    public void setTranscode(boolean enable) {
        this.transcode = enable;
    }

    public void setExportEventTag(String tag) {
        this.tag = tag;
    }

    public ClipDownloadInfo.StreamDownloadInfo getDownloadInfo() {
        return mDownloadInfo;
    }

    void setDownloadJobListener(DownloadJobListener listener) {
        mJobListener = listener;
    }

    @Override
    public Integer call() {
        try {
            if (TextUtils.isEmpty(url)) {
                downloadVideoSync();
            } else if (url.contains("http")) {
                downloadCloudSync();
            } else {
                if (needDewarp) {
                    startTranscoding(true);
                } else {
                    copyOriginFile();
                }
            }
            return 0;
        } catch (InterruptedException | ExecutionException th) {
            Logger.t(TAG).d("error = " + th.getMessage());
            onErrorClean();
            return -1;
        }
    }

    private void downloadCloudSync() {
        if (!needDewarp && transcode) {
            mDownloadFilePath = FileUtils.genDownloadVideoFileName(createTime);
        } else {
            mDownloadFilePath = FileUtils.genOriginVideoFileName(createTime);
        }

        Logger.t(TAG).i("mDownloadFilePath: " + mDownloadFilePath);

        //创建下载任务
        Network cellularNetwork = NetworkService.getCellularNetwork();
        try {
            if (cellularNetwork != null && NetworkUtils.isNetworkLimited()) {
                urlConnection = (HttpURLConnection) cellularNetwork.openConnection(new URL(url));
            } else {
                urlConnection = (HttpURLConnection) new URL(url).openConnection();
            }

            Map<String, String> cookie = CookieUtil.getCookie();
            if (!cookie.isEmpty()) {
                for (Map.Entry<String, String> next : cookie.entrySet()) {
                    //添加cookie
                    urlConnection.addRequestProperty(next.getKey(), next.getValue());
                }
            }

            InputStream inputStream;
            if (urlConnection.getResponseCode() == 200) {
                int fileSize = urlConnection.getContentLength();
                double total = 0;
                inputStream = urlConnection.getInputStream();
                File file = new File(mDownloadFilePath);
                FileOutputStream fos = new FileOutputStream(file);
                byte[] bytes = new byte[1024 * 10];
                int len;
                while ((len = inputStream.read(bytes)) != -1) {
                    fos.write(bytes, 0, len);
                    total += len;
                    Logger.t(TAG).d("notifyProgressChanged: " + total * 100 / fileSize);
                    notifyProgressChanged((int) (total * 100 / fileSize * 0.5));
                }
                fos.flush();
                fos.close();
                inputStream.close();

                notifyProgressChanged((int) (100 * 0.5));
                MediaScannerConnection.scanFile(WaylensCamera.getInstance().getApplicationContext(),
                        new String[]{
                                mDownloadFilePath}, null, null);
                Logger.t(TAG).d("onExportFinished " + mDownloadFilePath);

                if (needDewarp && transcode) {
                    startTranscoding(true);
                } else {
                    onExportFinished();
                }
            } else {
                onErrorClean();
            }
        } catch (IOException e) {
            e.printStackTrace();
            onErrorClean();
        }
    }

    private void downloadVideoSync() throws InterruptedException, ExecutionException {

        Clip.ID cid = mClip.cid;
//        Logger.t(TAG).d("%s", ToStringUtils.getString(cid));
        ClipDownloadInfo clipDownloadInfo;
        if (mStreamIndex == Clip.STREAM_MAIN) {
            clipDownloadInfo = SnipeApi.getClipDownloadInfo(cid,
                    mClip.getStartTimeMs() + mOffset, mDuration,
                    DownloadUrlRequest.DOWNLOAD_OPT_MAIN_STREAM, mStreamIndex);
            mDownloadInfo = clipDownloadInfo.main;
        } else if (mStreamIndex == Clip.STREAM_SUB) {
            clipDownloadInfo = SnipeApi.getClipDownloadInfo(cid,
                    mClip.getStartTimeMs() + mOffset, mDuration,
                    DownloadUrlRequest.DOWNLOAD_OPT_SUB_STREAM_1, mStreamIndex);
            mDownloadInfo = clipDownloadInfo.sub;
        } else {
            clipDownloadInfo = SnipeApi.getClipDownloadInfo(cid,
                    mClip.getStartTimeMs() + mOffset, mDuration,
                    DownloadUrlRequest.DOWNLOAD_OPT_SUB_STREAM_N, mStreamIndex);
            mDownloadInfo = clipDownloadInfo.subN;
        }
//        Logger.t(TAG).d("download info main = " + ToStringUtils.getString(clipDownloadInfo.main));
//        Logger.t(TAG).d("download info sub = " + ToStringUtils.getString(clipDownloadInfo.sub));

        Logger.t(TAG).d("%s", ToStringUtils.getString(mDownloadInfo));
        mDownloadHelper = new ClipDownloadHelper(mStreamInfo, mDownloadInfo);

        if (!needDewarp && transcode) {
            mDownloadFilePath = FileUtils.genDownloadVideoFileName(mDownloadInfo.clipDate, mDownloadInfo.clipTimeMs);
        } else {
            mDownloadFilePath = FileUtils.genOriginVideoFileName(mDownloadInfo.clipDate, mDownloadInfo.clipTimeMs);
        }

        Logger.t(TAG).i("mDownloadFilePath: " + mDownloadFilePath);

        notifyDownloadInfo();
        File videoDir = new File(FileUtils.getVideoExportPath());
        if (videoDir.getUsableSpace() < 2 * mDownloadInfo.size) {
            Logger.t(TAG).e("getUsableSpace: " + videoDir.getUsableSpace() + "--" + 2 * mDownloadInfo.size);
            /* no enough space */
            onErrorClean();
            return;
        }

        mDownloadHelper.downloadClipRx(mDownloadFilePath)
//                .observeOn(Schedulers.io())
                .subscribe(new Observer<Integer>() {
                    @Override
                    public void onError(Throwable e) {
                        downloadError = true;
                        synchronized (mDownloadFence) {
                            mDownloadFence.notifyAll();
                        }
                    }

                    @Override
                    public void onComplete() {
                        MediaScannerConnection.scanFile(WaylensCamera.getInstance().getApplicationContext(),
                                new String[]{
                                        mDownloadFilePath}, null, null);
                        Logger.t(TAG).d("onExportFinished " + mDownloadFilePath);
                        synchronized (mDownloadFence) {
                            mDownloadFence.notifyAll();
                        }
                    }

                    @Override
                    public void onSubscribe(Disposable d) {
                        mDownloadSub = d;
                    }

                    @Override
                    public void onNext(Integer integer) {
                        notifyProgressChanged((int) (integer * 0.5));
                    }
                });

        synchronized (mDownloadFence) {
            mDownloadFence.wait();
        }
        Logger.t(TAG).d("download finished " + mDownloadFilePath);
//        if (downloadError) {
//
//        }
        // 当视频需要dewarp时，才需要转码
        if (needDewarp && transcode) {
            startTranscoding(false);
        } else {
            onExportFinished();
        }
    }

    public void cancel() {
        if (mDownloadSub != null && !mDownloadSub.isDisposed()) {
            mDownloadSub.dispose();
        }
        mDownloadFence.notifyAll();
    }

    private void copyOriginFile() {
        mOutputFile = FileUtils.genDownloadVideoFileName(createTime);
        Logger.t(TAG).d("copyOriginFile: " + mOutputFile);
        mTmpOutputFile = mOutputFile;

        File file = new File(url);
        if (file.exists()) {
            File outputFile = new File(mTmpOutputFile);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                downloadAboveQ(file, outputFile);
            } else {
                downloadCommon(file, outputFile);
            }
        } else {
            onErrorClean();
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.Q)
    private void downloadAboveQ(File inputFile, File outputFile) {
        try {
            ContentValues values = new ContentValues();
            values.put(MediaStore.Downloads.DISPLAY_NAME, outputFile.getName());
            values.put(MediaStore.Downloads.MIME_TYPE, "video/mp4");
            values.put(MediaStore.Downloads.DATE_TAKEN, System.currentTimeMillis());
            values.put(MediaStore.Downloads.RELATIVE_PATH, "Download" + FileUtils.VIDEO_EXPORT_PATH);
            Uri uri = context.getContentResolver().insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values);
            InputStream inputStream = new FileInputStream(inputFile);
            OutputStream os = null;
            if (uri != null) {
                os = context.getContentResolver().openOutputStream(uri);
            }
            if (os != null) {
                byte[] buf = new byte[1024 * 16];
                int len;
                long progress = 0;
                while ((len = inputStream.read(buf)) != -1) {
                    os.write(buf, 0, len);
                    progress += len;
                    double tmp = (double) progress / inputFile.length() * 100;
                    Logger.t(TAG).d("copy progress = %f", tmp);
                    notifyProgressChanged((int) (tmp));
                }
                os.flush();
                inputStream.close();
                os.close();

                onTranscodeFinished();
                Logger.t(TAG).d("downloadAboveQ transcode finished " + outputFile.getAbsolutePath());
            } else {
                onErrorClean();
            }
        } catch (IOException e) {
            e.printStackTrace();
            onErrorClean();
        }
    }

    private void downloadCommon(File inputFile, File outputFile) {
        try {
            InputStream inputStream = new FileInputStream(inputFile);
            OutputStream outputStream = new FileOutputStream(outputFile);
            byte[] buf = new byte[1024 * 16];
            int len;
            long progress = 0;
            while ((len = inputStream.read(buf)) > 0) {
                outputStream.write(buf, 0, len);
                progress += len;
                double tmp = (double) progress / inputFile.length() * 100;
                Logger.t(TAG).d("copy progress = %f", tmp);
                notifyProgressChanged((int) (tmp));
            }
            outputStream.flush();
            inputStream.close();
            outputStream.close();

            onTranscodeFinished();
            Logger.t(TAG).d("downloadCommon transcode finished " + outputFile.getAbsolutePath());

        } catch (IOException e) {
            e.printStackTrace();
            onErrorClean();
        }
    }

    private void startTranscoding(boolean isClip) {
        //mState = TRANS_STATE_TRANCODING;
        //exportStatus.setText(R.string.transcoding);
        if (isClip) {
            mOutputFile = FileUtils.genDownloadVideoFileName(createTime);
        } else {
            mOutputFile = FileUtils.genDownloadVideoFileName(mDownloadInfo.clipDate, mDownloadInfo.clipTimeMs);
        }
        Logger.t(TAG).d("startTranscoding: " + mOutputFile);
        mTmpOutputFile = mOutputFile;

        String inputPath;
        if (TextUtils.isEmpty(url) || url.contains("http")) {
            inputPath = mDownloadFilePath;
        } else {
            inputPath = url;
        }

        mTranscoder = WLVideoTranscoder.getInstance();

        mTranscoder.initWithInputFile(inputPath, needDewarp, mLensNormal);

        WLVideoDewarpParams dewarpParams = new WLVideoDewarpParams();
        dewarpParams.renderMode = fullScreen ? WLVideoDewarpParams.WLVideoRenderMode.immersive : WLVideoDewarpParams.WLVideoRenderMode.split;
        WLVideoDewarpParams.WLDewarpDirection dewarpDirection = new WLVideoDewarpParams.WLDewarpDirection();
        dewarpDirection.horizontalAngle = angle;
        dewarpParams.dewarpDirection = dewarpDirection;
        dewarpParams.showTimeStamp = enableTime;
        mTranscoder.setDewarpParams(dewarpParams);

        mTranscoder.setOutputParam(mTmpOutputFile, WLVideoTranscoder.WLVideoTranscodeResolution.WL_1080p, 25000);

        final long startTime = SystemClock.uptimeMillis();
        mTranscoder.setListener(new WLVideoTranscoder.Listener() {
            @Override
            public void onTranscodeProgress(double v) {
                if (Thread.currentThread().isInterrupted()) {
                    mTranscoder.cancel();
                    return;
                }
                Logger.t(TAG).d("transcode progress = %f", v * 100);
                if (TextUtils.isEmpty(url) || url.contains("http")) {
                    notifyProgressChanged(50 + (int) (v * 100 * 0.5));
                } else {
                    //只转码
                    notifyProgressChanged((int) (v * 100));
                }
            }

            @Override
            public void onTranscodeCompleted() {
                mTranscoder.release();
                onTranscodeFinished();
                Logger.t(TAG).d("transcode finished " + mTmpOutputFile);
            }

            @Override
            public void onTranscodeFailed(Exception e) {
//                        onTranscodeError(e);
                Logger.t(TAG).d("transcode error %s", e.getMessage());
                onErrorClean();
            }
        });

        new Thread(() -> mTranscoder.start()).start();

//        Uri fileUri;
//        if (TextUtils.isEmpty(url) || url.contains("http")) {
//            fileUri = Uri.fromFile(new File(mDownloadFilePath));
//        } else {
//            fileUri = Uri.fromFile(new File(url));
//        }
//        ContentResolver resolver = context.getContentResolver();
//        final ParcelFileDescriptor parcelFileDescriptor;
//        final FileDescriptor fileDescriptor;
//        try {
//            parcelFileDescriptor = resolver.openFileDescriptor(fileUri, "r");
//            fileDescriptor = parcelFileDescriptor != null ? parcelFileDescriptor.getFileDescriptor() : null;
//        } catch (Exception e) {
//            e.printStackTrace();
//            onErrorClean();
//            return;
//        }

//        MediaTranscoder.getInstance().transcodeVideoRx(fullScreen, enableTime, angle, mLensNormal, needDewarp, fileDescriptor, mTmpOutputFile, getMediaFormatStrategy(), null, null)
////                .subscribeOn(Schedulers.io())
//                .subscribe(new Observer<MediaTranscoder.TranscodeProgress>() {
//                    Disposable disposable;
//
//                    @Override
//                    public void onSubscribe(Disposable d) {
//                        this.disposable = d;
//                    }
//
//                    @Override
//                    public void onNext(MediaTranscoder.TranscodeProgress transcodeProgress) {
//                        if (Thread.currentThread().isInterrupted()) {
//                            MediaTranscoder.getInstance().cancel();
//                            return;
//                        }
//                        Logger.t(TAG).d("transcode progress = %f", transcodeProgress.progress * 100);
//                        if (TextUtils.isEmpty(url) || url.contains("http")) {
//                            notifyProgressChanged(50 + (int) (transcodeProgress.progress * 100 * 0.5));
//                        } else {
//                            //只转码
//                            notifyProgressChanged((int) (transcodeProgress.progress * 100));
//                        }
//                    }
//
//                    @Override
//                    public void onError(Throwable e) {
//                        if (disposable != null && !disposable.isDisposed()) {
//                            disposable.dispose();
//                        }
//
////                        onTranscodeError(e);
//                        Logger.t(TAG).d("transcode error %s", e.getMessage());
//                        onErrorClean();
//                    }
//
//                    @Override
//                    public void onComplete() {
//                        if (disposable != null && !disposable.isDisposed()) {
//                            disposable.dispose();
//                        }
//
//                        MediaTranscoder.getInstance().release();
//                        notifyFinished(null);
//                        onTranscodeFinished();
//                        Logger.t(TAG).d("transcode finished " + mTmpOutputFile);
//                    }
//                });
    }

    private void onExportFinished() {
        if (mDownloadFilePath == null) {
            return;
        }

        VideoItem videoItem = null;

        File file = new File(mDownloadFilePath);
        if (file.exists()) {
            callMediaScanner(file);
            videoItem = insertDb(mDownloadFilePath, null);
        }

        notifyFinished(videoItem);

        if (mJobListener != null) {
            mJobListener.onComplete(getKey());
        }
    }

    private void onTranscodeFinished() {
        if (mTmpOutputFile == null)
            return;

//        if (Constants.isFleet() && Constants.isInstaller() && needDewarp) {
//            File file = new File(mDownloadFilePath);
//            if (file.exists()) {
//                boolean delete = file.delete();
//                Logger.t(TAG).d("origin video delete result: " + delete);
//                if (delete) {
//                    mDownloadFilePath = null;
//                }
//            }
//        }

        File tmpOutputFile = new File(mTmpOutputFile);
        VideoItem videoItem = null;
        if (tmpOutputFile.exists()) {
            callMediaScanner(tmpOutputFile);
            if (TextUtils.isEmpty(url) || url.contains("http")) {
                videoItem = insertDb(mDownloadFilePath, mTmpOutputFile);
            }
        }
        notifyFinished(videoItem);

        if (mJobListener != null) {
            mJobListener.onComplete(getKey());
        }
    }

    private VideoItem insertDb(String rawPath, String transcodePath) {
        VideoItem videoItem = new VideoItem();
        JSONObject jsonObject = new JSONObject();
        if (mClip != null) {
            videoItem.setCreateTime(DateTime.toDateTime(mDownloadInfo.clipDate, mDownloadInfo.clipTimeMs));
            //异步获取video location，更新到数据库
            getClipLocation(mClip, videoItem);
            videoItem.setType(mClip.getVideoType());
            videoItem.setDuration(mDuration);
            videoItem.setLensMode(mClip.isLensNormal() ? Clip.LENS_NORMAL : Clip.LENS_UPSIDEDOWN);
            try {
                jsonObject.put(VideoItem.KEY_NEED_DEWARP, mClip.getNeedDewarp());
            } catch (JSONException e) {
                Logger.t(TAG).e("put needDewarp error: " + e.getMessage());
            }
        } else {
            videoItem.setCreateTime(createTime);
            videoItem.setLocation(location);
            videoItem.setType(type);
            videoItem.setDuration(mDuration);
            videoItem.setLensMode(mLensNormal ? Clip.LENS_NORMAL : Clip.LENS_UPSIDEDOWN);
            try {
                jsonObject.put(VideoItem.KEY_NEED_DEWARP, needDewarp);
            } catch (JSONException e) {
                Logger.t(TAG).e("put needDewarp error: " + e.getMessage());
            }
        }
        if (jsonObject.has(VideoItem.KEY_NEED_DEWARP)) {
            videoItem.setGeneral(jsonObject.toString());
        }
        if (!TextUtils.isEmpty(rawPath)) {
            videoItem.setRawVideoPath(rawPath);
        }
        if (!TextUtils.isEmpty(transcodePath)) {
            videoItem.setTranscodeVideoPath(transcodePath);
        }
        LocalVideoDaoManager.getInstance().insert(videoItem);
        return videoItem;
    }

    private void getClipLocation(Clip firstClip, VideoItem videoItem) {
        //set location
//        Disposable subscribe = SnipeApi.getRawDataBlockRx(firstClip, RawDataItem.DATA_TYPE_GPS,
//                firstClip.getStartTimeMs(), 5 * 60 * 1000)
//                .compose(Transformers.switchSchedulers())
//                .subscribe((RawDataBlock rawDataBlock) -> {
//                    List<RawDataItem> rawDataBlockItemList = rawDataBlock.getItemList();
////                    Logger.t(TAG).d("rawDataBlock: " + rawDataBlockItemList.size());
//
//                    GpsData gpsData = null;
//                    for (RawDataItem item : rawDataBlockItemList) {
//                        gpsData = (GpsData) item.data;
//                        if (gpsData != null) {
////                            Logger.t(TAG).d("rawDataBlock index: " + rawDataBlockItemList.indexOf(item));
//                            break;
//                        }
//                    }
//
//                    GpsData.Coord coord = gpsData == null ? null : gpsData.coord;
////                    Logger.t(TAG).d("coord: " + coord);
//
//                    if (coord != null) {
//                        double lat = Double.parseDouble(String.format(Locale.ENGLISH, "%.4f", coord.lat));
//                        double lng = Double.parseDouble(String.format(Locale.ENGLISH, "%.4f", coord.lng));
////                        Logger.t(TAG).d("lat = " + lat + ", lng = " + lng);
//                        ApiService.createApiService().getLocation(lat, lng)
//                                .compose(Transformers.switchSchedulers())
//                                .subscribe((LocationResponse response) -> {
////                                    Logger.t(TAG).d("getLocation onHandleSuccess: " + response.getAddress());
//                                    LocationResponse.AddressBean address = response.getAddress();
//                                    if (address != null && !TextUtils.isEmpty(address.getRoute())) {
//                                        videoItem.setLocation(address.getRoute());
//                                        LocalVideoDaoManager.getInstance().update(videoItem);
//                                    }
//                                }, throwable -> Logger.t(TAG).e("throwable: " + throwable.getMessage()));
//                    }
//                }, throwable -> Logger.t(TAG).e("throwable: " + throwable.getMessage()));
    }

    private void callMediaScanner(File file) {
        /*
         for Samsung phones, add metadata to media store
         */
        ContentValues values = new ContentValues();
        values.put(MediaStore.Video.Media.DATA, file.getAbsolutePath());
        values.put(MediaStore.Video.Media.MIME_TYPE, FileUtils.getMimeType(file.getAbsolutePath()));
        try {
            context.getContentResolver().insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values);
        } catch (Exception e) {
            Logger.t(TAG).e("Failed to insert video into MediaStore");
            e.printStackTrace();
        }

        MediaScannerConnection.scanFile(context, new String[]{file.getPath()}, null, (path, uri) -> {
            Logger.t(TAG).d("media path = %s", path);
//            Logger.t(TAG).d("media uri = %s", uri.getPath());
        });
    }

    private void onErrorClean() {
        notifyDownloadError();
//        Logger.t(TAG).d("job listener = " + mJobListener);
        if (mJobListener != null) {
            mJobListener.onComplete(getKey());
        }

        if (mDownloadHelper != null) {
            mDownloadHelper.release();
        }

        if (urlConnection != null) {
            urlConnection.disconnect();
        }

        File file = new File(mDownloadFilePath);
        if (file.exists()) {
            boolean delete = file.delete();
        }
        File finalFile = new File(mOutputFile);
        if (finalFile.exists()) {
            boolean delete = finalFile.delete();
        }

        File tmpOutputFile = new File(mTmpOutputFile);
        if (tmpOutputFile.exists()) {
            boolean delete = tmpOutputFile.delete();
        }
    }

//    private MediaFormatStrategy getMediaFormatStrategy() {
//        switch (2) {
//            case 1:
//                return MediaFormatStrategyPresets.createAndroid720pStrategy();
//            case 2:
//                return MediaFormatStrategyPresets.createAndroid1080pStrategy();
//            default:
//                return MediaFormatStrategyPresets.createAndroid360pStrategy();
//        }
//    }

    @Override
    public int getExportProgress() {
        return mDownloadProgress;
    }

    @Override
    public String getOutputFile() {
        return mDownloadFilePath;
    }

    @Override
    public ClipPos getClipStartPos() {
        return new ClipPos(mClip);
    }
}
