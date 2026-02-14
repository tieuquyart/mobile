package com.mkgroup.camera.firmware;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mkgroup.camera.bean.Firmware;
import com.mkgroup.camera.bean.FirmwareBean;
import com.mkgroup.camera.utils.FileUtils;
import com.mkgroup.camera.utils.HashUtils;
import com.mkgroup.camera.utils.Hex;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.preference.PreferenceUtils;

import java.io.File;
import java.io.IOException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

import io.reactivex.disposables.Disposable;
import io.reactivex.subjects.PublishSubject;
import io.reactivex.subjects.Subject;

/**
 * Created by DoanVT on 17/4/11.
 * Email: doanvt-hn@mk.com.vn
 */
public class FirmwareManager {
    public static String TAG = FirmwareManager.class.getSimpleName();

    private boolean hasShownUpgradeDialog = false;

    public void setHasShownUpgradeDialog(boolean hasShown) {
        hasShownUpgradeDialog = hasShown;
    }

    public boolean getHasShownUpgradeDialog() {
        return hasShownUpgradeDialog;
    }

    public FirmwareManager() {
        mSubject = PublishSubject.<FirmwareDownloader.DownloadInfo>create().toSerialized();
        mDownloadObserver = new FirmwareDownloader.DownLoadObserver() {
            @Override
            public void onError(Throwable e) {
                super.onError(e);
                mSubject.onNext(downloadInfo);
            }

            @Override
            public void onComplete() {
                if (downloadInfo != null) {
                    downloadInfo.setIsComplete(true);
                    mSubject.onNext(downloadInfo);
                }
            }

            @Override
            public void onSubscribe(Disposable d) {

            }

            @Override
            public void onNext(FirmwareDownloader.DownloadInfo info) {
                super.onNext(info);
                //Logger.t(TAG).d("download info progress = " + downloadInfo.getProgress());
                if (info.getIsComplete()) {
                    Logger.t(TAG).d("download firmware " + info.getUrl() + "finished");
                }
                mSubject.onNext(info);
                //Logger.t(TAG).d("onNext here");
            }
        };
        mFirmwareDownloader = new FirmwareDownloader(mDownloadObserver);
        Gson gson = new Gson();
        latestFirmwareList = gson.fromJson(PreferenceUtils.getString(PreferenceUtils.KEY_LATEST_FIRMWARE_LIST, null),
                new TypeToken<List<Firmware>>() {
                }.getType());
        if (latestFirmwareList == null) {
            latestFirmwareList = new ArrayList<>();
        }
        latestFleetFirmware = gson.fromJson(PreferenceUtils.getString(PreferenceUtils.KEY_LATEST_FLEET_FIRMWARE, null), new TypeToken<FirmwareBean>() {
        }.getType());
    }

    public FirmwareDownloader.DownloadInfo checkFirmware(String url, String md5) {
        String fileName = url.substring(url.lastIndexOf("/"));
        File expectedFirmware = new File(FileUtils.getFirmwareDirectory(), fileName);
        Logger.t(TAG).d("output file: " + expectedFirmware);
        Logger.t(TAG).d("output file exist: " + expectedFirmware.exists());
        if (expectedFirmware.exists()) {
            boolean result = startFirmwareMd5Check(expectedFirmware, md5);
            Logger.t(TAG).d("startFirmwareMd5Check result: " + result);
            FirmwareDownloader.DownloadInfo downloadInfo;
            if (result) {
                downloadInfo = new FirmwareDownloader.DownloadInfo(url);
                downloadInfo.setIsComplete(true);
            } else {
                downloadInfo = mFirmwareDownloader.createDownInfo(url);
                downloadInfo = mFirmwareDownloader.checkDownloadInfo(downloadInfo);
            }
            return downloadInfo;
        }
        return null;
    }

    public boolean isDownloading(String url) {
        return mFirmwareDownloader.isDownloading(url);
    }

    private boolean startFirmwareMd5Check(File file, String md5) {
        try {
            final String downloadFileMd5 = Hex.encodeHexString(HashUtils.encodeMD5(file));
            return downloadFileMd5.equals(md5);
        } catch (IOException | NoSuchAlgorithmException e) {
            Logger.t(TAG).d("startFirmwareMd5Check throwable: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    private FirmwareDownloader mFirmwareDownloader;

    private FirmwareDownloader.DownLoadObserver mDownloadObserver;

    private Subject<FirmwareDownloader.DownloadInfo> mSubject;

    private List<Firmware> latestFirmwareList;

    private FirmwareBean latestFleetFirmware;

    public Subject<FirmwareDownloader.DownloadInfo> getDownloadSubject() {
        return mSubject;
    }

    public void downloadFirmware(String url) {
        if (!isDownloading(url)) {
            Logger.t(TAG).d("start a new download call");
            mFirmwareDownloader.downLoad(url);
        } else {
            Logger.t(TAG).d("already in downloading");
        }
    }

    public void cancelDownloadFirmware(String url) {
        mFirmwareDownloader.cancel(url);
    }

    public List<Firmware> getLatestFirmwareList() {
        return latestFirmwareList;
    }

    public FirmwareBean getLatestFleetFirmware() {
        return latestFleetFirmware;
    }

    public void updateLatestFirmwareList(List<Firmware> firmwareList) {
        latestFirmwareList = firmwareList;
        Gson gson = new Gson();
        PreferenceUtils.putString(PreferenceUtils.KEY_LATEST_FIRMWARE_LIST, gson.toJson(firmwareList));
    }

    public void updateLatestFleetFirmware(FirmwareBean firmware) {
        latestFleetFirmware = firmware;
        Gson gson = new Gson();
        PreferenceUtils.putString(PreferenceUtils.KEY_LATEST_FLEET_FIRMWARE, gson.toJson(firmware));
    }

    public void setDownloadedFirmware(Firmware firmware) {
        Gson gson = new Gson();
        String downloadedFirmware = gson.toJson(firmware);
        PreferenceUtils.putString(PreferenceUtils.KEY_DOWNLOADED_FIRMWARE, downloadedFirmware);
    }

    public Firmware getDownloadedFirmware() {
        String downloadedFirmware = PreferenceUtils.getString(PreferenceUtils.KEY_DOWNLOADED_FIRMWARE, null);
        Gson gson = new Gson();
        if (downloadedFirmware == null) {
            return null;
        } else {
            return gson.fromJson(downloadedFirmware, new TypeToken<Firmware>() {
            }.getType());
        }
    }
}
