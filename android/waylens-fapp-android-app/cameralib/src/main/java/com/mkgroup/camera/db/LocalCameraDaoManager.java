package com.mkgroup.camera.db;

import android.text.TextUtils;

import com.mkgroup.camera.WaylensCamera;

import org.greenrobot.greendao.query.QueryBuilder;

import java.util.List;

/**
 * Created by DoanVT on 2017/11/22.
 * Email: doanvt-hn@mk.com.vn
 */

public class LocalCameraDaoManager {

    private static final String TAG = LocalCameraDaoManager.class.getSimpleName();
    private static volatile LocalCameraDaoManager mInstance = null;
    private CameraItemDao mCameraItemDao;

    private LocalCameraDaoManager() {
        DaoSession daoSession = WaylensCamera.getInstance().getDaoSession();
        mCameraItemDao = daoSession.getCameraItemDao();
    }

    public static LocalCameraDaoManager getInstance() {
        if (mInstance == null) {
            synchronized (LocalCameraDaoManager.class) {
                if (mInstance == null) {
                    mInstance = new LocalCameraDaoManager();
                }
            }
        }
        return mInstance;
    }

    public boolean update(CameraItem cameraItem) {
        mCameraItemDao.save(cameraItem);
        return true;
    }

    public boolean insert(CameraItem cameraItem) {
        mCameraItemDao.insert(cameraItem);
        return true;
    }

    public void delete(CameraItem cameraItem) {
        mCameraItemDao.delete(cameraItem);
    }

    public boolean isInCameraDb(String sn) {
        QueryBuilder<CameraItem> qb = mCameraItemDao.queryBuilder();
        qb.where(CameraItemDao.Properties.SerialNumber.eq(sn));
        return !qb.list().isEmpty();
    }

    public List<CameraItem> getAllCameraItems() {
        return mCameraItemDao.loadAll();
    }

    public void deleteAll() {
        mCameraItemDao.deleteAll();
    }

    public CameraItem getCameraItem(String sn) {
        if (TextUtils.isEmpty(sn)) {
            return null;
        }
        QueryBuilder<CameraItem> qb = mCameraItemDao.queryBuilder();
        qb.where(CameraItemDao.Properties.SerialNumber.eq(sn));
        return qb.list().size() > 0 ? qb.list().get(0) : null;
    }

    public CameraItem getLatestConnectedCamera() {
        QueryBuilder<CameraItem> qb = mCameraItemDao.queryBuilder();
        qb.orderDesc(CameraItemDao.Properties.LastConnectingTime);
        return qb.list().size() > 0 ? qb.list().get(0) : null;
    }
}