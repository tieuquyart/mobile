package com.mk.autosecure.libs.utils;

import com.mkgroup.camera.bean.CameraBean;
import com.mkgroup.camera.bean.FleetCameraBean;
import com.mkgroup.camera.db.CameraItem;
import com.mkgroup.camera.db.LocalCameraDaoManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by doanvt on 2018/8/28.
 * Email：doanvt-hn@mk.com.vn
 */

public class SortUtil {

    private final static String TAG = SortUtil.class.getSimpleName();

    /**
     * @param oldCameras
     * @return 先判断相机的在线情况，再判断在线时间的先后
     */
    public static ArrayList<CameraBean> sort(ArrayList<CameraBean> oldCameras) {
        Collections.sort(oldCameras, (o1, o2) -> {
            Boolean isOnline1 = o1.isOnline;
            Boolean isOnline2 = o2.isOnline;
            if (isOnline1 && isOnline2) {
                return sortTime(o1, o2);
            } else if (isOnline2) {
                return 1;
            } else if (isOnline1) {
                return -1;
            } else {
                return sortTime(o1, o2);
            }
        });
        return oldCameras;
    }

    private static int sortTime(CameraBean o1, CameraBean o2) {
        //本地缓存最近一次连接时间和服务器接口相机最近一次上线时间做对比
        CameraItem item1 = LocalCameraDaoManager.getInstance().getCameraItem(o1.sn);
        CameraItem item2 = LocalCameraDaoManager.getInstance().getCameraItem(o2.sn);
        long lastConnectingTime1 = 0;
        if (item1 != null) {
            lastConnectingTime1 = item1.getLastConnectingTime();
//            Logger.t(TAG).d("lastConnectingTime1: " + lastConnectingTime1);
        }
        long lastConnectingTime2 = 0;
        if (item2 != null) {
            lastConnectingTime2 = item2.getLastConnectingTime();
//            Logger.t(TAG).d("lastConnectingTime2: " + lastConnectingTime2);
        }

        long sortTime1 = Math.max(
                o1.thumbnailTime == null ? 0 : o1.thumbnailTime,
                o1.onlineStatusChangeTime == null ? 0 : o1.onlineStatusChangeTime);
        sortTime1 = Math.max(sortTime1, lastConnectingTime1);

        long sortTime2 = Math.max(
                o2.thumbnailTime == null ? 0 : o2.thumbnailTime,
                o2.onlineStatusChangeTime == null ? 0 : o2.onlineStatusChangeTime);
        sortTime2 = Math.max(sortTime2, lastConnectingTime2);

        //防止long值转为int溢出
        return sortTime2 - sortTime1 >= 0 ? 1 : -1;
    }

    public static List<FleetCameraBean> sortFleet(List<FleetCameraBean> oldCameras) {
        return oldCameras;
    }
}
