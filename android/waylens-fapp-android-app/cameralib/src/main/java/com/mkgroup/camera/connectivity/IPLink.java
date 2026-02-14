package com.mkgroup.camera.connectivity;

import com.mkgroup.camera.VdtCameraManager;
import com.mkgroup.camera.command.EvCameraCmdConsts;
import com.mkgroup.camera.command.VdtCameraCmdConsts;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.VdtCamera;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * Created by doanvt on 2018/9/4.
 * Email：doanvt-hn@mk.com.vn
 */

public class IPLink {

    private final static String TAG = IPLink.class.getSimpleName();
    public final static String IP_VDTCAM = "192.168.110.1";
    public final static String IP_EVCAM = "192.168.119.1";

    /**
     * 强制连接固定IP
     */
    public static void linkIP() {
        linkVdtCam();
        linkEvCam();
    }

    public static void linkVdtCam() {
        connectVdtCam();
        connectOldEvCam();
    }

    public static void linkEvCam() {
        connectNewEvCam();
    }

    private static void connectVdtCam() {
        try {
            InetAddress byName = InetAddress.getByName(IP_VDTCAM);

            if (byName == null) {
                return;
            }
            boolean reachable = byName.isReachable(1000);
            Logger.t(TAG).d("connectVdtCam ip reachable: " + reachable);

            if (reachable) {
                VdtCamera.ServiceInfo serviceInfo = new VdtCamera.ServiceInfo(byName, VdtCameraCmdConsts.VDT_CAM_PORT,
                        "horn", "", false);
                VdtCameraManager.getManager().connectCamera(serviceInfo, "IPLink_VdtCamera");
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectVdtCam UnknownHostException: " + e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectVdtCam IOException: " + e.getMessage());
        }
    }

    private static void connectOldEvCam() {
        try {
            InetAddress byName = InetAddress.getByName(IP_VDTCAM);

            if (byName == null) {
                return;
            }
            boolean reachable = byName.isReachable(1000);
            Logger.t(TAG).d("connectOldEvCam ip reachable: " + reachable);

            if (reachable) {
                VdtCamera.ServiceInfo serviceInfo = new VdtCamera.ServiceInfo(byName, EvCameraCmdConsts.EV_CAM_PORT,
                        "horn", "", false);
                VdtCameraManager.getManager().connectCamera(serviceInfo, "IPLink_OldEvCamera");
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectOldEvCam UnknownHostException: " + e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectOldEvCam IOException: " + e.getMessage());
        }
    }

    private static void connectNewEvCam() {
        try {
            InetAddress byName = InetAddress.getByName(IP_EVCAM);

            if (byName == null) {
                return;
            }
            boolean reachable = byName.isReachable(1000);
            Logger.t(TAG).d("connectNewEvCam ip reachable: " + reachable);

            if (reachable) {
                VdtCamera.ServiceInfo serviceInfo = new VdtCamera.ServiceInfo(byName, EvCameraCmdConsts.EV_CAM_PORT,
                        "fleet", "", false);
                VdtCameraManager.getManager().connectCamera(serviceInfo, "IPLink_NewEvCamera");
            }
        } catch (UnknownHostException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectNewEvCam UnknownHostException: " + e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
            Logger.t(TAG).e("connectNewEvCam IOException: " + e.getMessage());
        }
    }

}
