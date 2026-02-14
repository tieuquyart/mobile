package com.mkgroup.camera.db;

import android.text.TextUtils;

import com.mkgroup.camera.WaylensCamera;
import com.orhanobut.logger.Logger;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static com.mkgroup.camera.model.Clip.LENS_NORMAL;

/**
 * Created by DoanVT on 2017/11/22.
 * Email: doanvt-hn@mk.com.vn
 */

public class LocalVideoDaoManager {

    private static final String TAG = LocalVideoDaoManager.class.getSimpleName();
    private static volatile LocalVideoDaoManager mInstance = null;
    private VideoItemDao mVideoItemDao;

    private LocalVideoDaoManager() {
        DaoSession daoSession = WaylensCamera.getInstance().getDaoSession();
        mVideoItemDao = daoSession.getVideoItemDao();
    }

    public static LocalVideoDaoManager getInstance() {
        if (mInstance == null) {
            synchronized (LocalVideoDaoManager.class) {
                if (mInstance == null) {
                    mInstance = new LocalVideoDaoManager();
                }
            }
        }
        return mInstance;
    }

    public boolean update(VideoItem videoItem) {
        mVideoItemDao.save(videoItem);
        return true;
    }

    public boolean insert(VideoItem videoItem) {
        mVideoItemDao.insert(videoItem);
        return true;
    }

    public void delete(VideoItem videoItem) {
        mVideoItemDao.delete(videoItem);
    }

//    public boolean isInCameraDb(String sn) {
//        QueryBuilder<CameraItem> qb = mVideoItemDao.queryBuilder();
//        qb.where(CameraItemDao.Properties.SerialNumber.eq(sn));
//        return !qb.list().isEmpty();
//    }

    public List<VideoItem> getAllVideoItems() {
        return mVideoItemDao.loadAll();
    }

    public void deleteAll() {
        mVideoItemDao.deleteAll();
    }

    public List<VideoItem> getVideoList() {
        List<VideoItem> videoItemList = new ArrayList<>();

        LocalVideoDaoManager daoManager = LocalVideoDaoManager.getInstance();
        List<VideoItem> allVideoItems = daoManager.getAllVideoItems();

        for (VideoItem item : allVideoItems) {
            String rawVideoPath = item.getRawVideoPath();
            if (TextUtils.isEmpty(rawVideoPath)) {
                String transcodeVideoPath = item.getTranscodeVideoPath();
                if (TextUtils.isEmpty(transcodeVideoPath)) {
                    daoManager.delete(item);
                } else {
                    File file = new File(transcodeVideoPath);
                    if (file.exists()) {
                        setDefaultLensMode(item);
                        videoItemList.add(item);
                    } else {
                        daoManager.delete(item);
                    }
                }
            } else {
                File file = new File(rawVideoPath);
                if (file.exists()) {
                    setDefaultLensMode(item);
                    videoItemList.add(item);
                } else {
                    daoManager.delete(item);
                }
            }
        }
        Collections.sort(videoItemList, (o1, o2) -> o2.getCreateTime() - o1.getCreateTime() > 0 ? 1 : -1);
        return videoItemList;
    }

    private boolean setDefaultLensMode(VideoItem item) {
        String lensMode = item.getLensMode();
        Logger.t(TAG).d("curLensMode: " + lensMode);

        if (TextUtils.isEmpty(lensMode)) {
            item.setLensMode(LENS_NORMAL);
            boolean update = update(item);
            Logger.t(TAG).d("setDefaultLensMode: " + update);
            return update;
        }
        return false;
    }

//    public CameraItem getCameraItem(String sn) {
//        QueryBuilder<CameraItem> qb = mVideoItemDao.queryBuilder();
//        qb.where(CameraItemDao.Properties.SerialNumber.eq(sn));
//        return qb.list().size() > 0 ? qb.list().get(0) : null;
//    }

//    public CameraItem getLatestConnectedCamera() {
//        QueryBuilder<CameraItem> qb = mVideoItemDao.queryBuilder();
//        qb.orderDesc(CameraItemDao.Properties.LastConnectingTime);
//        return qb.list().size() > 0 ? qb.list().get(0) : null;
//    }

}