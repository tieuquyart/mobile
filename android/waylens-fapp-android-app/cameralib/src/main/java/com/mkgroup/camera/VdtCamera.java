package com.mkgroup.camera;

import static com.mkgroup.camera.command.EvCameraCmdConsts.CAT.CMD_CAT_DEVICE;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getCameraLog;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_AUDIO_SET_MIC;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_BT_DO_BIND;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_BT_DO_SCAN;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_BT_DO_UNBIND;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_BT_GET_DEV_STATUS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_BT_GET_HOST_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_BT_GET_HOST_NUM;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_BT_IS_ENABLED;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_FORMAT_TF;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_GET_API_VERSION;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_GET_GET_ALL_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_GET_GET_STORAGE_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_GET_NAME;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_GET_NAME_RESULT;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_GET_STATE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_GET_STATE_RESULT;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_GET_TIME_RESULT;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_MSG_BATTERY_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_MSG_GPS_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_MSG_MIC_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_MSG_POWER_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_MSG_STORAGE_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_MSG_STORAGE_SPACE_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_SET_NAME;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_START_REC;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_CAM_STOP_REC;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_Copy_DebugLog;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_Copy_Log;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_FACTORY_RESET;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_FW_GET_VERSION;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_FW_Get_Key;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_FW_NEW_VERSION;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GETMARKSTORAGE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_APN;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_ATTITUDE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_AUDIO_PROMPTS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_AUTO_POWER_OFF_DELAY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_DISPLAY_AUTO_OFF_TIME;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_DISPLAY_BRIGHTNESS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_EVENT_DETECTION_PARAM;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_HDR_MODE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_ICCID;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_LAPTRACKS_INFO;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_LAPTRACKS_UPDATE_PORT;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_LTE_FWVERSION;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_LTE_STATUS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_MONITOR_MODE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_MOUNT_ACCEL_LEVELS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_MOUNT_ACCEL_PARAM;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_MOUNT_ACC_TRUST;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_MOUNT_MW_SENSITIVITY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_MOUNT_SETTINGS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_MOUNT_VERSION;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_P2P_ENABLE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_P2P_PAIREDLIST;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_PARK_SLEEP_DELAY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_PROTECTION_VOLTAGE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_SCREEN_SAVER_STYLE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_SPEAKER_STATUS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_SUPPORT_RISK_DRIVE_EVENT;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_GET_VIRTUAL_IGNITION;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_Get_360_Server;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_IMAGE_RECOGNITION_RESULT;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_ADD_HOST;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_CONNECTHOTSPOT;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_CONNECT_HOST;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_GET_DEVICETIME;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_GET_HOST_INFOR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_GET_HOST_NUM;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_GET_WLAN_MODE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_RMV_HOST;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_SCANHOST;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_NETWORK_SYNCTIME;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_REC_ERROR;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SETMARKSTORAGE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_APN;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_ATTITUDE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_AUTO_POWER_OFF_DELAY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_DISPLAY_AUTO_OFF_TIME;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_DISPLAY_BRIGHTNESS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_EVENT_DETECTION_PARAM;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_HDR_MODE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_MOUNT_ACCEL_LEVELS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_MOUNT_ACC_TRUST;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_MOUNT_MW_SENSITIVITY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_MOUNT_SETTINGS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_P2P_ENABLE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_PARK_SLEEP_DELAY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_PROTECTION_VOLTAGE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_REMOVE_P2P_PAIREDDEV;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_SCREEN_SAVER_STYLE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_SUPPORT_RISK_DRIVE_EVENT;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SET_VIRTUAL_IGNITION;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SUPPORT_UPSIDEDOWN;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_SUPPORT_WLAN_MODE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.CAM.CMD_Set_360_Server;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.DOMAIN.CMD_DOMAIN_CAM;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.DOMAIN.CMD_DOMAIN_REC;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_GET_COLOR_MODE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_GET_MARK_TIME;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_GET_OVERLAY_STATE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_GET_QUALITY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_GET_REC_MODE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_GET_RESOLUTION;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_GET_ROTATE_MODE;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_GET_SUB_STREAM_ONLY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_LIST_COLOR_MODES;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_LIST_QUALITIES;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_LIST_REC_MODES;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_LIST_RESOLUTIONS;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_MARK_LIVE_VIDEO;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_SET_MARK_TIME;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_SET_OVERLAY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_SET_QUALITY;
import static com.mkgroup.camera.command.VdtCameraCmdConsts.REC.CMD_REC_SET_SUB_STREAM_ONLY;

import com.mkgroup.camera.message.bean.AuxCfgModel;
import com.mkgroup.camera.message.bean.CustomMK;
import com.mkgroup.camera.message.bean.EnableBean;
import com.mkgroup.camera.message.bean.HotspotInfoModel;
import com.mkgroup.camera.message.bean.MountSetting;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.command.VdtCameraCmdConsts;
import com.mkgroup.camera.direct.PairedDevices;
import com.mkgroup.camera.event.CameraStateChangeEvent;
import com.mkgroup.camera.event.FormatSDCardEvent;
import com.mkgroup.camera.event.HostsChangeEvent;
import com.mkgroup.camera.event.MarkLiveMsgEvent;
import com.mkgroup.camera.event.MountParamChangeEvent;
import com.mkgroup.camera.event.StreamRecordChangeEvent;
import com.mkgroup.camera.event.VideoQualityChangeEvent;
import com.mkgroup.camera.log.CmdRequestFuture;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

public class VdtCamera extends CameraWrapper implements VdtCameraCmdConsts {

    private static final String TAG = VdtCamera.class.getSimpleName();

    public VdtCamera(ServiceInfo serviceInfo, OnConnectionChangeListener listener) {
        super(serviceInfo, listener);
    }

//    public String versionString() {
//        int main = (mApiVersion >> 16) & 0xff;
//        int sub = mApiVersion & 0xffff;
//        return String.format(Locale.US, "%d.%d.%s", main, sub, mBuild);
//    }

    public static int getHalfMarkTime() {
        return HALF_MARK_TIME_MS;
    }

    @Override
    public String getApiVersion() {
        mCommunicationBus.sendCAMCommand(CMD_CAM_GET_API_VERSION, "", "");
        return mApiVersionStr;
    }

    @Override
    public String getPassword() {
        mCommunicationBus.sendCAMCommand(CMD_FW_Get_Key, "", "");
        return mPassword;
    }

    @Override
    public String getCameraServer() {
        mCommunicationBus.sendCAMCommand(CMD_Get_360_Server, "", "");
        return mCameraServer;
    }

    @Override
    public void setCameraServer(String server) {
        mCameraServer = server;
        mCommunicationBus.sendCAMCommand(CMD_Set_360_Server, server, "");
    }

    @Override
    public CmdRequestFuture<Integer> prepareLog() {
        CmdRequestFuture<Integer> future = CmdRequestFuture.newFuture();
        prepareLogFuture = future;
        mCommunicationBus.sendCAMCommand(CMD_Copy_Log, "", "");
        return future;
    }

    @Override
    public CmdRequestFuture<Integer> prepareDebugLog() {
        CmdRequestFuture<Integer> future = CmdRequestFuture.newFuture();
        prepareLogFuture = future;
        mCommunicationBus.sendCAMCommand(CMD_Copy_DebugLog, "", "");
        return future;
    }

    @Override
    public CmdRequestFuture<Integer> prepareLog(String date) {
        CmdRequestFuture<Integer> future = CmdRequestFuture.newFuture();
        prepareLogFuture = future;
        if (date != null && !date.equals("")) {
            CustomMK body = new CustomMK(date);
            mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getCameraLog, gson.toJson(body));
        } else {

            mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getCameraLog, "");
        }
        return future;
    }

    public boolean getGpsState() {
        mCommunicationBus.sendCAMCommand(CMD_CAM_MSG_GPS_INFOR, "", "");
        return mGpsState > 0;
    }

    public void refreshBatteryInfo() {
        mCommunicationBus.sendCAMCommand(CMD_CAM_MSG_BATTERY_INFOR, "", "");
    }

    @Override
    public void queryStorageState() {
        mCommunicationBus.sendCAMCommand(CMD_CAM_GET_GET_STORAGE_INFOR, "", "");
    }

    @Override
    public int getMonitorMode() {
        mCommunicationBus.sendCAMCommand(CMD_GET_MONITOR_MODE, "", "");
        return monitorMode;
    }

    @Override
    public void factoryReset() {
        mCommunicationBus.sendCAMCommand(CMD_FACTORY_RESET, "", "");
    }

//    public String getServerName() {
//        return mServiceInfo.serverName;
//    }

//    public int getBtState() {
//        return mBtState;
//    }

//    public void getIsBtEnabled() {
//        mCommunicationBus.sendCAMCommand(CMD_CAM_BT_IS_ENABLED, "", "");
//    }

//    public boolean getIfRotated() {
//        return mIfRotate;
//    }

    @Override
    public void setMicEnabled(boolean enabled) {
//        Logger.t(TAG).d("setMicEnabled: " + enabled);
        int micState = enabled ? STATE_MIC_ON : STATE_MIC_OFF;
        mCommunicationBus.sendCAMCommand(CMD_AUDIO_SET_MIC, Integer.toString(micState), Integer.toString(mMicVol));
    }

    @Override
    public void setAudioPromptsEnabled(boolean enabled) {
//        Logger.t(TAG).d("setAudioPromptsEnabled: " + enabled);
        String promptsState = enabled ? "on" : "off";
        mCommunicationBus.sendCAMCommand(CAM.CMD_SET_AUDIO_PROMPTS, promptsState, "");
    }

    @Override
    public void setLensNormal(boolean isNormal) {
        String attitude = isNormal ? LENS_NORMAL : LENS_UPSIDEDOWN;
        mCommunicationBus.sendCAMCommand(CMD_SET_ATTITUDE, attitude, "");
    }

    @Override
    public void removePaired(String mac) {
        mCommunicationBus.sendCAMCommand(CMD_SET_REMOVE_P2P_PAIREDDEV, mac, "");
    }

//    public void setAutoPowerOffDelay(String autoPowerOffDelay) {
//        Logger.t(TAG).d(autoPowerOffDelay);
//        mCommunicationBus.sendCAMCommand(CMD_SET_AUTO_POWER_OFF_DELAY, autoPowerOffDelay, "");
//        mAutoPowerOffDelay = autoPowerOffDelay;
//    }

//    public String getScreenSaverStyle() {
//        Logger.t(TAG).d(String.format("getScreenSaverStyle" + mScreenSaverStyle));
//        mCommunicationBus.sendCAMCommand(CMD_GET_SCREEN_SAVER_STYLE, "", "");
//        return mScreenSaverStyle;
//    }

//    public void setScreenSaverStyle(String screenSaverStyle) {
//        Logger.t(TAG).d(screenSaverStyle);
//        mCommunicationBus.sendCAMCommand(CMD_SET_SCREEN_SAVER_STYLE, screenSaverStyle, "");
//    }

    @Override
    public int getWifiMode() {
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_WLAN_MODE, "", "");
        return mWifiMode;
    }

    public void setWifiMode(int wifiMode) {
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_CONNECT_HOST, Integer.toString(wifiMode), "");
    }

    public List<String> getHostList() {
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_HOST_NUM, "", "");
        return mSsidList;
    }

    @Override
    public String getBspFirmware() {
        mCommunicationBus.sendCAMCommand(CMD_FW_GET_VERSION, "", "");
        return mBspVersion;
    }

    @Override
    public void sendNewFirmware(int size, String md5, OnNewFwVersionListener listener) {
        Logger.t(TAG).i("sendNewFirmware: " + size + " " + md5);
        mOnNewFwVersionListener = listener;
        mCommunicationBus.sendCAMCommand(CMD_FW_NEW_VERSION, md5, "");
    }

//    public String getSSID() {
//        return mServiceInfo.ssid;
//    }

//    public int getVideoResolution() {
//        mCommunicationBus.sendRECCommand(CMD_REC_GET_RESOLUTION, "", "");
//        Logger.t(TAG).d("get video quality index: " + mVideoResolutionIndex);
//        switch (mVideoResolutionIndex) {
//            case VIDEO_RESOLUTION_1080P30:
//            case VIDEO_RESOLUTION_1080P60:
//                return VIDEO_RESOLUTION_1080P;
//            default:
//                return VIDEO_RESOLUTION_720P;
//        }
//    }

//    private void setVideoResolution(int resolutionIndex) {
//        mVideoResolutionIndex = resolutionIndex;
//        mCommunicationBus.sendRECCommand(CMD_REC_SET_RESOLUTION, Integer.toString(resolutionIndex), "");
//    }

//    public int getVideoResolutionFramerate() {
//        mCommunicationBus.sendRECCommand(CMD_REC_GET_RESOLUTION, "", "");
//        return mVideoResolutionIndex;
//    }

//    public String getVideoResolutionStr() {
//        mCommunicationBus.sendRECCommand(CMD_REC_GET_RESOLUTION, "", "");
//        Logger.t(TAG).d("video resolution index: " + mVideoResolutionIndex);
//        switch (mVideoResolutionIndex) {
//            case VIDEO_RESOLUTION_1080P30:
//                return "1080p30";
//            case VIDEO_RESOLUTION_1080P60:
//                return "1080p60";
//            case VIDEO_RESOLUTION_720P30:
//                return "720p30";
//            case VIDEO_RESOLUTION_720P60:
//                return "720p60";
//            case VIDEO_RESOLUTION_720P120:
//                return "720p120";
//            default:
//                return "Unknown";
//        }
//    }

//    public int getVideoFramerate() {
//        mCommunicationBus.sendRECCommand(CMD_REC_GET_RESOLUTION, "", "");
//        Logger.t(TAG).d("get video quality index: " + mVideoResolutionIndex);
//        switch (mVideoResolutionIndex) {
//            case VIDEO_RESOLUTION_1080P60:
//            case VIDEO_RESOLUTION_720P60:
//            case VIDEO_RESOLUTION_4KP60:
//            case VIDEO_RESOLUTION_480P60:
//                return VIDEO_FRAMERATE_60FPS;
//            case VIDEO_RESOLUTION_720P120:
//                return VIDEO_FRAMERATE_120FPS;
//            default:
//                return VIDEO_FRAMERATE_30FPS;
//        }
//    }

//    public int getRecordMode() {
//        return mRecordModeIndex;
//    }


//    public InetSocketAddress getPreviewAddress() {
//        return mPreviewAddress;
//    }


//    public void registerRawDataItemMsgHandler() {
//        Logger.t(TAG).d("registerRawDataItemMsgHandler");
//    }

//    public void unregisterRawDataItemMagHandler() {
//        Logger.t(TAG).d("unregisterRawDataItemMagHandler");
//        if (mVdbRequestQueue != null) {
//            mVdbRequestQueue.unregisterMessageHandler(VdbCommand.Factory.MSG_RawData);
//        }
//    }


    @Override
    public void handleMessage(int domain, int code, String p1, String p2) {
        //Logger.t(TAG).d("code = %d, p1 = %s, p2 = %s", code, p1, p2);
        switch (domain) {
            case CMD_DOMAIN_CAM:
                handleCameraMessage(code, p1, p2);
                break;
            case CMD_DOMAIN_REC:
                handleRecordMessage(code, p1, p2);
                break;
        }
    }

    @Override
    public void handleEvCamMessage(String category, String msg, String body) {
        //do nothing
    }

    @Override
    public void initCameraState() {
        mCommunicationBus.sendCAMCommand(CMD_CAM_GET_API_VERSION, "", "");
        mCommunicationBus.sendCAMCommand(CMD_FW_GET_VERSION, "", "");

        mCommunicationBus.sendCAMCommand(CMD_CAM_GET_NAME, "", "");
        mCommunicationBus.sendCAMCommand(CMD_FW_Get_Key, "", "");
        mCommunicationBus.sendCAMCommand(CMD_CAM_MSG_MIC_INFOR, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_AUDIO_PROMPTS, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_ACC_TRUST, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_VIRTUAL_IGNITION, "", "");

        mCommunicationBus.sendCAMCommand(CMD_Get_360_Server, "", "");

        mCommunicationBus.sendCAMCommand(CMD_GET_ICCID, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_LTE_FWVERSION, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_LTE_STATUS, "", "");

        mCommunicationBus.sendCAMCommand(CMD_GET_P2P_ENABLE, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_P2P_PAIREDLIST, "", "");

        mCommunicationBus.sendCAMCommand(CMD_SUPPORT_UPSIDEDOWN, "", "");

        mCommunicationBus.sendCAMCommand(CMD_GETMARKSTORAGE, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_ACCEL_LEVELS, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_ACCEL_PARAM, "customized", "");

        mCommunicationBus.sendRECCommand(CMD_REC_GET_QUALITY, "", "");
        mCommunicationBus.sendRECCommand(CMD_REC_LIST_QUALITIES, "", "");

        mCommunicationBus.sendRECCommand(CMD_REC_GET_REC_MODE, "", "");
        mCommunicationBus.sendRECCommand(CMD_REC_GET_RESOLUTION, "", "");
        mCommunicationBus.sendRECCommand(CMD_REC_LIST_RESOLUTIONS, "", "");
        mCommunicationBus.sendCAMCommand(CMD_CAM_GET_GET_ALL_INFOR, "", "");
        mCommunicationBus.sendCAMCommand(CMD_CAM_GET_STATE, "", "");
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_WLAN_MODE, "", "");
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_HOST_NUM, "", "");
        mCommunicationBus.sendRECCommand(CMD_REC_GET_MARK_TIME, "", "");
        mCommunicationBus.sendCAMCommand(CMD_CAM_MSG_BATTERY_INFOR, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_SPEAKER_STATUS, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_DISPLAY_BRIGHTNESS, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_DISPLAY_AUTO_OFF_TIME, "", "");
        mCommunicationBus.sendRECCommand(CMD_REC_GET_OVERLAY_STATE, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_AUTO_POWER_OFF_DELAY, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_SCREEN_SAVER_STYLE, "", "");
        mCommunicationBus.sendCAMCommand(CMD_CAM_BT_IS_ENABLED, "", "");
        mCommunicationBus.sendRECCommand(CMD_REC_GET_ROTATE_MODE, "", "");
        mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_VERSION, "", "");
        getMountSettings(true);
        getHdrMode();
        getMonitorMode();

        mCommunicationBus.sendCAMCommand(CMD_GET_SUPPORT_RISK_DRIVE_EVENT, "", "");

        mCommunicationBus.sendCAMCommand(CMD_GET_APN, "", "");

        mCommunicationBus.sendCAMCommand(CMD_SUPPORT_WLAN_MODE, "", "");

        mCommunicationBus.sendCAMCommand(CMD_GET_PROTECTION_VOLTAGE, "", "");

        mCommunicationBus.sendCAMCommand(CMD_GET_PARK_SLEEP_DELAY, "", "");

    }

//    public void setBtEnable(boolean enable) {
//        mCommunicationBus.sendCAMCommand(CMD_CAM_BT_ENABLE, Integer.toString(enable ? 1 : 0), "");
//        Logger.t(TAG).d("sent CMD_CAM_BT_ENABLE");
//    }

//    public void scanBluetoothDevices() {
//        mCommunicationBus.sendCAMCommand(CMD_CAM_BT_DO_SCAN, "", "");
//    }

//    public void getBtHostNumber() {
//        mCommunicationBus.sendCAMCommand(CMD_CAM_BT_GET_HOST_NUM, "", "");
//    }

//    @Override
//    public void doBtUnbind(int type, String mac) {
//        Logger.t(TAG).d("cmd_CAM_BT_doUnBind, type=" + type + ", mac=" + mac);
//        mCommunicationBus.sendCAMCommand(CMD_CAM_BT_DO_UNBIND, Integer.toString(type), mac);
//    }

//    @Override
//    public void doBind(int type, String mac) {
//        Logger.t(TAG).d("cmd_CAM_BT_doBind, type=" + type + ", mac=" + mac);
//        mCommunicationBus.sendCAMCommand(CMD_CAM_BT_DO_BIND, Integer.toString(type), mac);
//    }

    @Override
    public String getName() {
        mCommunicationBus.sendCAMCommand(CMD_CAM_GET_NAME, "", "");
        return mCameraName;
    }

    @Override
    public void setName(String name) {
        mCameraName = name;
        mCommunicationBus.sendCAMCommand(CMD_CAM_SET_NAME, name, "");
    }

//    public void setVideoResolution(int resolution, int frameRate) {
//        int videoResulution = VIDEO_RESOLUTION_1080P30;
//        if (resolution == VIDEO_RESOLUTION_1080P) {
//            switch (frameRate) {
//                case VIDEO_FRAMERATE_30FPS:
//                    videoResulution = VIDEO_RESOLUTION_1080P30;
//                    break;
//                case VIDEO_FRAMERATE_60FPS:
//                    videoResulution = VIDEO_RESOLUTION_1080P60;
//                    break;
//            }
//        } else if (resolution == VIDEO_RESOLUTION_720P) {
//            switch (frameRate) {
//                case VIDEO_FRAMERATE_30FPS:
//                    videoResulution = VIDEO_RESOLUTION_720P30;
//                    break;
//                case VIDEO_FRAMERATE_60FPS:
//                    videoResulution = VIDEO_RESOLUTION_720P60;
//                    break;
//                case VIDEO_FRAMERATE_120FPS:
//                    videoResulution = VIDEO_RESOLUTION_720P120;
//                    break;
//
//            }
//        }
//        Logger.t(TAG).d("set video resolution: " + videoResulution);
//        setVideoResolution(videoResulution);
//    }

    @Override
    public MountSetting getMountSettings(boolean refresh) {
        if (refresh) mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_SETTINGS, "", "");
        return mountSetting;
    }

    @Override
    public void setMountSettings(String setting) {
        mCommunicationBus.sendCAMCommand(CMD_SET_MOUNT_SETTINGS, setting, "");
    }

    @Override
    public int getHdrMode() {
        mCommunicationBus.sendCAMCommand(CMD_GET_HDR_MODE, "", "");
        return hdr_mode;
    }

    @Override
    public void setHdrMode(int hdrMode) {
        String mode = "on";
        switch (hdrMode) {
            case HDR_MODE_ON:
                mode = "on";
                break;
            case HDR_MODE_OFF:
                mode = "off";
                break;
            case HDR_MODE_AUTO:
                mode = "auto";
                break;
        }
//        Logger.t(TAG).e("setHdrMode: " + mode);
        mCommunicationBus.sendCAMCommand(CMD_SET_HDR_MODE, mode, "");
    }

    @Override
    public void sendFormatSDCard() {
        mCommunicationBus.sendCAMCommand(CMD_CAM_FORMAT_TF, "", "");
    }

    public void setStreamQuality(int mainIndex, int subIndex) {
        mMainStreamQuality = mainIndex;
        mSubStreamQuality = subIndex;
        mCommunicationBus.sendRECCommand(CMD_REC_SET_QUALITY, Integer.toString(mainIndex), Integer.toString(subIndex));
    }

    public int getMainStreamQuality() {
        mCommunicationBus.sendRECCommand(CMD_REC_GET_QUALITY, "", "");
        return mMainStreamQuality;
    }

    public int getSubStreamQuality() {
        mCommunicationBus.sendRECCommand(CMD_REC_GET_QUALITY, "", "");
        return mSubStreamQuality;
    }

//    public void getRecordColorMode() {
//        mCommunicationBus.sendRECCommand(CMD_REC_GET_COLOR_MODE, "", "");
//    }

//    public void setRecordRecMode(int flags) {
//        mCommunicationBus.sendRECCommand(CMD_REC_SET_REC_MODE, Integer.toString(flags), "");
//    }

//    public void getRecordRecMode() {
//        mCommunicationBus.sendRECCommand(CMD_REC_GET_REC_MODE, "", "");
//    }

//    public void startPreview() {
//        mCommunicationBus.sendCAMCommand(CMD_CAM_WANT_PREVIEW, "", "");
//    }

//    public int getRecordTime() {
//        mCommunicationBus.sendCAMCommand(CMD_CAM_GET_TIME, "", "");
//        return mRecordTime;
//    }

//    public void getRecordResolutionList() {
//        mCommunicationBus.sendRECCommand(CMD_REC_LIST_RESOLUTIONS, "", "");
//    }

    @Override
    public void markLiveVideo() {
        mCommunicationBus.sendRECCommand(CMD_REC_MARK_LIVE_VIDEO, "", "");
    }

//    public int getMarkBeforeTime() {
//        return mMarkBeforeTime;
//    }

//    @Override
//    public void setMarkTime(int before, int after) {
//        if (before < 0 || after < 0) {
//            return;
//        }
//        mCommunicationBus.sendRECCommand(CMD_REC_SET_MARK_TIME, Integer.toString(before), Integer.toString(after));
//    }

    @Override
    public void stopRecording() {
        Logger.t(TAG).i("stopRecording");
        mCommunicationBus.sendCAMCommand(CMD_CAM_STOP_REC, "", "");
    }

    @Override
    public void startRecording() {
        mCommunicationBus.sendCAMCommand(CMD_CAM_START_REC, "", "");
    }

    public int getNetworkHostHum() {
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_HOST_NUM, "", "");
        return mNumWifiAP;
    }

    public void setNetworkRmvHost(String ssid) {
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_RMV_HOST, ssid, "");
//        mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_HOST_NUM, "", "");
    }

    public void addNetworkHost(String ssid, String password) {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("ssid", ssid);
            jsonObject.put("password", password);
            jsonObject.put("is_hide", 0);

            Logger.t(TAG).d("addNetworkHost: " + jsonObject.toString());

            mCommunicationBus.sendCAMCommand(CMD_NETWORK_ADD_HOST, jsonObject.toString(), "");
//            mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_HOST_NUM, "", "");
        } catch (JSONException e) {
            Logger.t(TAG).e("addNetworkHost JSONException: " + e.getMessage());
        }
    }

    public void connectNetworkHost(String ssid) {
        if (ssid == null) {
            ssid = "";
        }
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_CONNECTHOTSPOT, ssid, "");
    }

    @Override
    public boolean isPromptsEnabled() {
        mCommunicationBus.sendCAMCommand(CMD_GET_AUDIO_PROMPTS, "", "");
        return mPromptsState == AUDIO_PROMPTS_MODE_ON;
    }

    @Override
    public String getIccid() {
        mCommunicationBus.sendCAMCommand(CMD_GET_ICCID, "", "");
        return mIccid;
    }

    @Override
    public void getDeviceTime() {
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_DEVICETIME, "", "");
    }

    @Override
    public void setDeviceTime(long syncTime, long syncTimeZone) {
        mCommunicationBus.sendCAMCommand(CMD_NETWORK_SYNCTIME, Long.toString(syncTime), Float.toString(syncTimeZone));
    }

    @Override
    public void getMountSensitivity() {
        mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_MW_SENSITIVITY, "", "");
    }

    @Override
    public HotspotInfoModel getHotspotInfo() {
        // TODO: 2021/1/16 10086 support
        return null;
    }

    @Override
    public void setHotspotInfo(String ssid, String key) {
        // TODO: 2021/1/16 10086 support
    }

    @Override
    public int getVirtualIgnition() {
        mCommunicationBus.sendCAMCommand(CMD_GET_VIRTUAL_IGNITION, "", "");
        return mVirtualIgnitionEnable;
    }

    @Override
    public void setVirtualIgnition(boolean enable) {
        EnableBean model = new EnableBean(enable);
        Logger.t(TAG).i("setVirtualIgnition: " + gson.toJson(model));
        mCommunicationBus.sendCAMCommand(CMD_SET_VIRTUAL_IGNITION, gson.toJson(model), "");
    }

    @Override
    public AuxCfgModel getAuxCfg() {
        return null;
    }

    @Override
    public void setAuxCfg(AuxCfgModel model, int angle) {

    }

    @Override
    public boolean isNightVisionInDrivingAvailable() {
        return compareToApiVersion("1.8.0") >= 0;
    }

    @Override
    public boolean isPowerCordTestAvailable() {
        return compareToApiVersion("1.9.01") >= 0;
    }

    @Override
    public boolean isMarkSpaceSettingsAvailable() {
        return compareToApiVersion("1.9.03") >= 0;
    }

    @Override
    public boolean isAudioPromptsAvailable() {
        return compareToApiVersion("1.9.03") >= 0;
    }

    @Override
    public boolean isModemVersionAvailable() {
        return compareToApiVersion("1.10.0") >= 0;
    }

    @Override
    public boolean isNetworkTestDiagnosisAvailable() {
        return compareToApiVersion("1.10.01") >= 0;
    }

    @Override
    public boolean isHDRAutoAvailable() {
        return compareToApiVersion("1.12.0") >= 0;
    }

    @Override
    public boolean isNightVisionAutoAvailable() {
        return compareToApiVersion("1.12.0") >= 0;
    }

    @Override
    public boolean isSupportUntrustACCWireAvailable() {
        return compareToApiVersion("1.12.0") >= 0;
    }

    @Override
    public boolean isWifiDirectAvailable() {
        return compareToApiVersion("1.13.0") >= 0;
    }

    @Override
    public boolean isDrivingModeTimeoutSettingsAvailable() {
        return compareToApiVersion("1.14.0") >= 0;
    }

    @Override
    public boolean isProtectionVoltageAvailable() {
        return compareToApiVersion("1.14.0") >= 0;
    }

    @Override
    public boolean isAPNSettingsAvailable() {
        return compareToApiVersion("1.14.0") >= 0;
    }

    @Override
    public boolean isSubStreamOnlyAvailable() {
        return compareToApiVersion("1.14.0") >= 0;
    }

    @Override
    public boolean isWLanModeAvailable() {
        return compareToApiVersion("1.14.0") >= 0;
    }

    @Override
    public boolean isRiskyDrivingEventAvailable() {
        return compareToApiVersion("1.14.0") >= 0;
    }

    @Override
    public boolean isVinMirrorAvailable() {
        return false;
    }

    @Override
    public boolean isMacWlan0Available() {
        return false;
    }

    @Override
    public boolean isSradarAvailable() {
        return false;
    }

    @Override
    public boolean isExBoardvailable() {
        return false;
    }
    @Override
    public boolean isRecordConfigAvailable() {
        return false;
    }

    @Override
    public boolean isCalibCameraAvailable() {
        return (mHardwareName.contains(EV_MODEL) || mHardwareName.contains(EV_TAG)) && compareToApiVersion("1.3.0") >= 0;
    }

    @Override
    public boolean isVirtualIgnitionAvailable() {
        return true;
    }

    @Override
    public boolean isAdasCfgAvailable() {
        return false;
    }

    @Override
    public boolean isAuxCfgAvailable() {
        return false;
    }

    @Override
    public int getRadarSensitivity() {
        mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_MW_SENSITIVITY, "", "");
        return mRadarSensitivity;
    }

    @Override
    public void setRadarSensitivity(int sensitivity) {
        mRadarSensitivity = sensitivity;
        mCommunicationBus.sendCAMCommand(CMD_SET_MOUNT_MW_SENSITIVITY, Integer.toString(sensitivity), "");
    }

    @Override
    public int getMountAccTrust() {
        mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_ACC_TRUST, "", "");
        return mMountAccTrust;
    }

    @Override
    public void setMountAccTrust(boolean trust) {
        mCommunicationBus.sendCAMCommand(CMD_SET_MOUNT_ACC_TRUST, Integer.toString(trust ? 1 : 0), "");
    }

    @Override
    public boolean getP2pEnable() {
        mCommunicationBus.sendCAMCommand(CMD_GET_P2P_ENABLE, "", "");
        return mP2pEnable;
    }

    @Override
    public void setP2pEnable(boolean enable) {
        mCommunicationBus.sendCAMCommand(CMD_SET_P2P_ENABLE, enable ? "1" : "0", "");
    }

    @Override
    public PairedDevices getPairedDevices() {
        mCommunicationBus.sendCAMCommand(CMD_GET_P2P_PAIREDLIST, "", "");
        return pairedDevices;
    }

    @Override
    public boolean getIsLensNormal() {
        mCommunicationBus.sendCAMCommand(CMD_GET_ATTITUDE, "", "");
        return mIsLensNormal;
    }

    public boolean getStreamSetting() {
        mCommunicationBus.sendRECCommand(CMD_REC_GET_SUB_STREAM_ONLY, "", "");
        return mSubStreamOnly;
    }

    public void setStreamSetting(boolean only) {
        mSubStreamOnly = only;
        mCommunicationBus.sendRECCommand(CMD_REC_SET_SUB_STREAM_ONLY, only ? "1" : "0", "");
    }

    @Override
    public String getApnSetting() {
        mCommunicationBus.sendCAMCommand(CMD_GET_APN, "", "");
        return mApnSetting;
    }

    @Override
    public void setApnSetting(String apn) {
        mApnSetting = apn;
        mCommunicationBus.sendCAMCommand(CMD_SET_APN, apn, "");
    }

    @Override
    public boolean getSupportWlan() {
        mCommunicationBus.sendCAMCommand(CMD_SUPPORT_WLAN_MODE, "", "");
        return mSupportWlan;
    }

    @Override
    public boolean getSupportRiskEvent() {
        mCommunicationBus.sendCAMCommand(CMD_GET_SUPPORT_RISK_DRIVE_EVENT, "", "");
        return mSupportRiskEvent;
    }

    @Override
    public void setSupportRiskEvent(boolean support) {
        mSupportRiskEvent = support;
        mCommunicationBus.sendCAMCommand(CMD_SET_SUPPORT_RISK_DRIVE_EVENT, String.valueOf(support ? 1 : 0), "");
    }

    @Override
    public String getEventParam() {
        mCommunicationBus.sendCAMCommand(CMD_GET_EVENT_DETECTION_PARAM, "", "");
        return mEventParam;
    }

    @Override
    public void setEventParam(String param) {
        mEventParam = param;
        mCommunicationBus.sendCAMCommand(CMD_SET_EVENT_DETECTION_PARAM, param, "");
    }

    @Override
    public int getProtectVoltage() {
        mCommunicationBus.sendCAMCommand(CMD_GET_PROTECTION_VOLTAGE, "", "");
        return mProtectVoltage;
    }

    @Override
    public void setProtectVoltage(int voltage) {
        mProtectVoltage = voltage;
        mCommunicationBus.sendCAMCommand(CMD_SET_PROTECTION_VOLTAGE, String.valueOf(voltage), "");
    }

    @Override
    public int getParkSleepDelay() {
        mCommunicationBus.sendCAMCommand(CMD_GET_PARK_SLEEP_DELAY, "", "");
        return mParkSleepDelay;
    }

    @Override
    public void setParkSleepDelay(int delay) {
        int time = 30;
        switch (delay) {
            case SLEEP_DELAY_30S:
                break;
            case SLEEP_DELAY_60S:
                time = 60;
                break;
            case SLEEP_DELAY_120S:
                time = 120;
                break;
            case SLEEP_DELAY_300S:
                time = 300;
                break;
            case SLEEP_DELAY_600S:
                time = 600;
                break;
        }
        mParkSleepDelay = time;
        mCommunicationBus.sendCAMCommand(CMD_SET_PARK_SLEEP_DELAY, String.valueOf(time), "");
    }

    @Override
    public String getModemVersion() {
        mCommunicationBus.sendCAMCommand(CMD_GET_LTE_FWVERSION, "", "");
        return modemVersion;
    }

    @Override
    public int getMarkStorage() {
        mCommunicationBus.sendCAMCommand(CMD_GETMARKSTORAGE, "", "");
        return mVideoSpace;
    }

    @Override
    public void setMarkStorage(int index) {
        if (videoSpaceList != null && index < videoSpaceList.length) {
            mVideoSpace = index;
            mCommunicationBus.sendCAMCommand(CMD_SETMARKSTORAGE, videoSpaceList[index], "");
        }
    }

    @Override
    public int getMountLevel() {
//            mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_ACCEL_LEVELS, "", "");
        return mMountLevel;
    }

    @Override
    public void setMountLevel(int index) {
        mMountLevel = index;

        mCommunicationBus.sendCAMCommand(CMD_SET_MOUNT_ACCEL_LEVELS, index == -1 ? "customized" : mountLevelList[index], "");
    }

//    public String[] getMountLevelList() {
////        mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_ACCEL_LEVELS, "", "");
//        return mountLevelList;
//    }

//    public String getMountParam() {
//        mCommunicationBus.sendCAMCommand(CMD_GET_MOUNT_ACCEL_PARAM, "", "");
//        return mMountParam;
//    }

//    public void setMountParam(String param) {
//        mMountParam = param;
//        mCommunicationBus.sendCAMCommand(CMD_SET_MOUNT_ACCEL_PARAM, "customized", param);
//    }

    private void handleCameraMessage(int cmd, String p1, String p2) {
        switch (cmd) {
            case CMD_CAM_GET_API_VERSION:
                ack_Cam_Get_ApiVersion(p1);
                break;
            case CMD_CAM_GET_NAME_RESULT:
                ack_Cam_Get_NameResult(p1);
                break;
            case CMD_CAM_GET_STATE_RESULT:
                ack_Cam_Get_StateResult(p1);
                break;
            case CMD_CAM_GET_TIME_RESULT:
                ack_Cam_Get_TimeResult(p1);
                break;
            case CMD_CAM_MSG_STORAGE_INFOR:
                ack_Cam_StorageInfo(p1, p2);
                break;
            case CMD_CAM_MSG_STORAGE_SPACE_INFOR:
                ack_Cam_StorageSpaceInfo(p1, p2);
                break;
            case CMD_CAM_MSG_BATTERY_INFOR:
                ack_Cam_BatteryInfo(p1);
                break;
            case CMD_CAM_MSG_POWER_INFOR:
                ack_Cam_PowerInfo(p1, p2);
                break;
            case CMD_CAM_MSG_GPS_INFOR:
                ack_Cam_GpsInfo(p1, p2);
                break;
            case CMD_CAM_MSG_MIC_INFOR:
                ack_Cam_MicInfo(p1, p2);
                break;
            case CMD_GET_AUDIO_PROMPTS:
                ack_Cam_Get_AudioPrompts(p1);
                break;
            case CMD_GETMARKSTORAGE:
                ack_Cam_Get_MarkStorage(p1, p2);
                break;
            case CMD_GET_MOUNT_ACCEL_LEVELS:
                ack_Cam_Get_MountAccelLevels(p1, p2);
                break;
            case CMD_GET_MOUNT_ACCEL_PARAM:
                ack_Cam_Get_MountAccelParam(p1);
                break;
            case CMD_NETWORK_GET_WLAN_MODE:
                ack_Cam_Get_WlanMode(p1, p2);
                break;
            case CMD_NETWORK_GET_HOST_NUM:
                ack_Cam_GetHostNum(p1, p2);
                break;
            case CMD_NETWORK_GET_HOST_INFOR:
                ack_Cam_GetHostInfo(p1, p2);
                break;
            case CMD_NETWORK_ADD_HOST:
                ack_Cam_AddHost(p1, p2);
                break;
            case CMD_NETWORK_RMV_HOST:
                ack_Cam_RemoveHost(p1, p2);
                break;
            case CMD_NETWORK_CONNECT_HOST:
                ack_Cam_ConnectHost(p1, p2);
                break;
            case CMD_NETWORK_SCANHOST:
                ack_Cam_ScanHost(p1, p2);
                break;
            case CMD_NETWORK_CONNECTHOTSPOT:
                ack_Cam_ConnectHotspot(p1, p2);
                break;
            case CMD_FW_GET_VERSION:
                ack_Cam_Get_FW_Version(p1, p2);
                break;
            case CMD_FW_NEW_VERSION:
                ack_Cam_Get_FW_NewVersion(p1);
                break;
            case CMD_CAM_BT_IS_ENABLED:
                ack_Cam_BT_IsEnabled(p1, p2);
                break;
            case CMD_CAM_BT_GET_DEV_STATUS:
                ack_Cam_Get_BT_DevStatus(p1, p2);
                break;
            case CMD_CAM_BT_GET_HOST_NUM:
                ack_Cam_Get_BT_HostNum(p1);
                break;
            case CMD_CAM_BT_GET_HOST_INFOR:
                ack_Cam_Get_BT_HostInfo(p1, p2);
                break;
            case CMD_CAM_BT_DO_SCAN:
                ack_Cam_BT_DoScan(p1);
                break;
            case CMD_CAM_BT_DO_BIND:
                ack_Cam_BT_DoBind(p1, p2);
                break;
            case CMD_CAM_BT_DO_UNBIND:
                ack_Cam_BT_DoUnbind(p1, p2);
                break;
            case CMD_GET_SPEAKER_STATUS:
                ack_Cam_Get_SpeakerStatus(p1, p2);
                break;
            case CMD_GET_DISPLAY_BRIGHTNESS:
                ack_Cam_Get_DisplayBrightness(p1);
                break;
            case CMD_SET_DISPLAY_BRIGHTNESS:
                ack_Cam_Set_DisplayBrightness(p1);
                break;
            case CMD_GET_DISPLAY_AUTO_OFF_TIME:
                ack_Cam_Get_DisplayAutoOffTime(p1);
                break;
            case CMD_SET_DISPLAY_AUTO_OFF_TIME:
                ack_Cam_Set_DisplayAutoOffTime(p1);
                break;
            case CMD_GET_AUTO_POWER_OFF_DELAY:
                ack_Cam_Get_AutoPowerOffDelay(p1);
                break;
            case CMD_SET_AUTO_POWER_OFF_DELAY:
                ack_Cam_Set_AutoPowerOffDelay(p1);
                break;
            case CMD_GET_SCREEN_SAVER_STYLE:
                ack_Cam_Get_ScreenSaverStyle(p1);
                break;
            case CMD_SET_SCREEN_SAVER_STYLE:
                ack_Cam_Set_ScreenSaverStyle(p1, p2);
                break;
            case CMD_NETWORK_SYNCTIME:
                ack_Cam_SyncTime(p1, p2);
                break;
            case CMD_NETWORK_GET_DEVICETIME:
                ack_Cam_Get_DeviceTime(p1, p2);
                break;
            case CMD_IMAGE_RECOGNITION_RESULT:
                ack_Cam_RecognitionResult(p1, p2);
                break;
            case CMD_GET_LAPTRACKS_UPDATE_PORT:
                ack_Cam_Get_LapTracksUpdatePort(p1, p2);
                break;
            case CMD_GET_LAPTRACKS_INFO:
                ack_Cam_Get_LapTracksInfo(p1, p2);
                break;
            case CMD_GET_MOUNT_SETTINGS:
                ack_Cam_Get_MountSettings(p1);
                break;
            case CMD_SET_MOUNT_SETTINGS:
                ack_Cam_Set_MountSettings(p1, p2);
                break;
            case CMD_CAM_FORMAT_TF:
                ack_Cam_FormatSDCard(p1);
                break;
            case CMD_GET_MOUNT_VERSION:
                ack_Cam_Get_MountVersion(p1);
                break;
            case CMD_SET_HDR_MODE:
                ack_Cam_Set_HdrMode(p1, p2);
                break;
            case CMD_GET_HDR_MODE:
                ack_Cam_Get_HdrMode(p1);
                break;
            case CMD_FACTORY_RESET:
                ack_Cam_FactoryReset(p1, p2);
                break;
            case CMD_FW_Get_Key:
                ack_Cam_FW_Get_Key(p1);
                break;
            case CMD_Get_360_Server:
                ack_Cam_Get_Server(p1);
                break;
            case CMD_Copy_Log:
                ack_Cam_CopyLog(p1);
                break;
            case CMD_Copy_DebugLog:
                ack_Cam_CopyLog(p1);
                break;
            case CMD_GET_MONITOR_MODE:
                ack_Cam_Get_MonitorMode(p1);
                break;
            case CMD_GET_ICCID:
                ack_Cam_Get_Iccid(p1);
                break;
            case CMD_GET_LTE_FWVERSION:
                ack_Cam_Get_LteVertion(p1, p2);
                break;
            case CMD_GET_LTE_STATUS:
                ack_Cam_Get_LteStatus(p1);
                break;
            case CMD_GET_MOUNT_MW_SENSITIVITY:
                ack_Cam_Get_MountSensitivity(p1);
                break;
            case CMD_GET_MOUNT_ACC_TRUST:
                ack_Cam_Get_MountAccTrust(p1);
                break;
            case CMD_GET_P2P_ENABLE:
                ack_Cam_Get_P2P_Enable(p1);
                break;
            case CMD_GET_P2P_PAIREDLIST:
                ack_Cam_Get_P2P_PairedList(p1);
                break;
            case CMD_SUPPORT_UPSIDEDOWN:
                ack_Cam_Support_Upsidedown(p1);
                break;
            case CMD_GET_ATTITUDE:
                ack_Cam_Get_Attitude(p1);
                break;
            case CMD_GET_EVENT_DETECTION_PARAM:
                ack_Cam_Get_EventDetectionParam(p1);
                break;
            case CMD_GET_SUPPORT_RISK_DRIVE_EVENT:
                ack_Cam_Get_SupportRiskDriveEvent(p1);
                break;
            case CMD_GET_APN:
                ack_Cam_Get_APN(p1);
                break;
            case CMD_SUPPORT_WLAN_MODE:
                ack_Cam_SupportWlanMode(p1);
                break;
            case CMD_GET_PROTECTION_VOLTAGE:
                ack_Cam_Get_ProtectionVoltage(p1);
                break;
            case CMD_SET_PROTECTION_VOLTAGE:
                ack_Cam_Set_ProtectionVoltage(p1);
                break;
            case CMD_GET_PARK_SLEEP_DELAY:
                ack_Cam_Get_ParkSleepDelay(p1);
                break;
            case CMD_SET_PARK_SLEEP_DELAY:
                ack_Cam_Set_ParkSleepDelay(p1);
                break;
            case CMD_GET_VIRTUAL_IGNITION:
                ack_Cam_Get_VirtualIgnition(gson.fromJson(p1, EnableBean.class).isEnable());
                break;
            case CMD_SET_VIRTUAL_IGNITION:
                ack_Cam_Set_VirtualIgnition(gson.fromJson(p1, EnableBean.class).isEnable());
                break;
            default:
//                Logger.t(TAG).d("ack " + cmd + " not handled, p1=" + p1 + ", p2=" + p2);
                break;
        }
    }

    private void ack_Cam_Set_ProtectionVoltage(String p1) {
//        Logger.t(TAG).d("ack_Cam_Set_ProtectionVoltage p1=" + p1 + ", p2=" + p2);
        int i = Integer.parseInt(p1);
        if (i == 1) {
            mCommunicationBus.sendCAMCommand(CMD_GET_PROTECTION_VOLTAGE, "", "");
        }
    }

    private void ack_Cam_Set_ParkSleepDelay(String p1) {
//        Logger.t(TAG).d("ack_Cam_Set_ParkSleepDelay p1=" + p1 + ", p2=" + p2);
        int i = Integer.parseInt(p1);
        if (i == 1) {
            mCommunicationBus.sendCAMCommand(CMD_GET_PARK_SLEEP_DELAY, "", "");
        }
    }

    private void ack_Cam_Set_VirtualIgnition(boolean enable) {
        Logger.t(TAG).i("ack_Cam_Set_VirtualIgnition enable=" + enable);
    }

    private void ack_Cam_RecognitionResult(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_RecognitionResult p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_Get_FW_NewVersion(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_FW_NewVersion p1=" + p1 + ", p2=" + p2);
        if (mOnNewFwVersionListener != null) {
            mOnNewFwVersionListener.onNewVersion(Integer.valueOf(p1));
        }
    }

    private void ack_Cam_ConnectHost(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_ConnectHost p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_ConnectHotspot(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_ConnectHotspot p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_AddHost(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_AddHost p1=" + p1 + ", p2=" + p2);
        int i = Integer.parseInt(p1);
        if (i == 1) {
            mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_HOST_NUM, "", "");
        }
    }

    private void ack_Cam_RemoveHost(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_RemoveHost p1=" + p1 + ", p2=" + p2);
        int i = Integer.parseInt(p1);
        if (i == 1) {
            mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_HOST_NUM, "", "");
        }
    }

    private void ack_Cam_ScanHost(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_ScanHost p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_Get_TimeResult(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_TimeResult p1=" + p1 + ", p2=" + p2);
        int duration = Integer.parseInt(p1);

        if (mRecordTime != duration) {
            mRxBus.post(new CameraStateChangeEvent(CameraStateChangeEvent.CAMERA_STATE_REC_DURATION, VdtCamera.this, duration));
            mRecordTime = duration;
        }
    }

    private void ack_Cam_StorageSpaceInfo(String p1, String p2) {
//        Logger.t(TAG).d("ack_Cam_StorageSpaceInfo p1=" + p1 + ", p2=" + p2);
        long totalSpace = p1.length() > 0 ? Long.parseLong(p1) : 0;
        long freeSpace = p2.length() > 0 ? Long.parseLong(p2) : 0;

        mStorageTotalSpace = totalSpace;
        mStorageFreeSpace = freeSpace;
    }

    private void ack_Cam_BatteryInfo(String p1) {
//        Logger.t(TAG).d("ack_Cam_BatteryInfo p1=" + p1 + ", p2=" + p2);
        try {
            JSONObject jsonObject = new JSONObject(p1);
            String batteryLevel = jsonObject.optString(POWER_INFO_KEY_CAPACITY_LEVEL);
            mBatteryLevel = getBatteryLevelWithString(batteryLevel);
            mVoltageNow = jsonObject.optInt(POWER_INFO_KEY_VOLTAGE_NOW);
//            int vol = Integer.parseInt(p2);
//            mBatteryVol = vol;
            statusSubject.onNext(this);
        } catch (Exception ex) {
            Logger.t(TAG).d("ack_Cam_BatteryInfo exception = " + ex.getMessage());
        }
    }

    private void ack_Cam_GpsInfo(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_GpsInfo p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_Get_MountAccelParam(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_MountAccelParam p1=" + p1 + ", p2=" + p2);
        mMountParam = p1;
        mRxBus.post(new MountParamChangeEvent(VdtCamera.this, mMountParam));
    }

    private void ack_Cam_Get_WlanMode(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_Get_WlanMode p1=" + p1 + ", p2=" + p2);
        mWifiMode = Integer.parseInt(p1);
    }

    private void ack_Cam_GetHostNum(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_GetHostNum p1=" + p1 + ", p2=" + p2);
        int num = Integer.parseInt(p1);
        mNumWifiAP = num;
        mSsidList.clear();

        for (int i = 0; i < num; i++) {
            mCommunicationBus.sendCAMCommand(CMD_NETWORK_GET_HOST_INFOR, Integer.toString(i), "");
        }
    }

    private void ack_Cam_GetHostInfo(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_GetHostInfo p1=" + p1 + ", p2=" + p2);
        boolean contains = mSsidList.contains(p1);
        if (!contains) {
            mSsidList.add(p1);
        }
        mRxBus.post(new HostsChangeEvent(VdtCamera.this, mSsidList));
    }

    private void ack_Cam_BT_IsEnabled(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_BT_IsEnabled p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_Get_BT_DevStatus(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_Get_BT_DevStatus p1=" + p1 + ", p2=" + p2);
//        int i_p1 = Integer.parseInt(p1);
//        int devType = i_p1 >> 8;
//        int devState = i_p1 & 0xff;
//        String mac = "";
//        String name = "";
//        int index = p2.indexOf('#');
//        if (index >= 0) {
//            mac = p2.substring(0, index);
//            name = p2.substring(index + 1);
//        }
    }

    private void ack_Cam_Get_BT_HostNum(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_BT_HostNum p1=" + p1);
        int numDevs = Integer.parseInt(p1);
        if (numDevs < 0) {
            numDevs = 0;
        }
        mScannedBtDeviceNumber = numDevs;
//        Logger.t(TAG).d("find devices: " + mScannedBtDeviceNumber);
        for (int i = 0; i < numDevs; i++) {
            mCommunicationBus.sendCAMCommand(CMD_CAM_BT_GET_HOST_INFOR, Integer.toString(i), "");
        }
    }

    private void ack_Cam_Get_BT_HostInfo(String name, String mac) {
        Logger.t(TAG).d("ack_Cam_Get_BT_HostInfo p1=" + name + ", p2=" + mac);
    }

    private void ack_Cam_BT_DoScan(String p1) {
//        Logger.t(TAG).d("ack_Cam_BT_DoScan p1=" + p1);
        int ret = Integer.parseInt(p1);
        if (ret == 0) {
            mCommunicationBus.sendCAMCommand(CMD_CAM_BT_GET_HOST_NUM, "", "");
        }
    }

    private void ack_Cam_BT_DoBind(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_BT_DoBind p1=" + p1 + ", p2=" + p2);

    }

    private void ack_Cam_BT_DoUnbind(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_BT_DoUnbind p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_Set_DisplayBrightness(String p1) {
//        Logger.t(TAG).d("ack_Cam_Set_DisplayBrightness p1=" + p1 + ", p2=" + p2);
        try {
            mDisplayBrightness = Integer.parseInt(p1);
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Set_DisplayBrightness exception = " + e.getMessage());
        }
    }

    private void ack_Cam_Get_DisplayBrightness(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_DisplayBrightness p1=" + p1 + ", p2=" + p2);
        try {
            mDisplayBrightness = Integer.parseInt(p1);
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Get_DisplayBrightness exception = " + e.getMessage());
        }
    }

    private void ack_Cam_Set_DisplayAutoOffTime(String p1) {
//        Logger.t(TAG).d("ack_Cam_Set_DisplayAutoOffTime p1=" + p1 + ", p2=" + p2);
        try {
            mAutoOffTime = p1;
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Set_DisplayAutoOffTime exception = " + e.getMessage());
        }
    }

    private void ack_Cam_Get_DisplayAutoOffTime(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_DisplayAutoOffTime p1=" + p1 + ", p2=" + p2);
        try {
            mAutoOffTime = p1;
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Get_DisplayAutoOffTime exception = " + e.getMessage());
        }
    }

    private void ack_Cam_Set_AutoPowerOffDelay(String p1) {
//        Logger.t(TAG).d("ack_Cam_Set_AutoPowerOffDelay p1=" + p1 + ", p2=" + p2);
        try {
            mAutoPowerOffDelay = p1;
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Set_AutoPowerOffDelay exception = " + e.getMessage());
        }
    }

    private void ack_Cam_Get_AutoPowerOffDelay(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_AutoPowerOffDelay p1=" + p1 + ", p2=" + p2);
        try {
            mAutoPowerOffDelay = p1;
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Get_AutoPowerOffDelay exception = " + e.getMessage());
        }
    }

    private void ack_Cam_Set_ScreenSaverStyle(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_Set_ScreenSaverStyle p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_SyncTime(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_SyncTime p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_Get_ScreenSaverStyle(String p1) {
//        Logger.t(TAG).d("ack_Cam_Get_ScreenSaverStyle p1=" + p1 + ", p2=" + p2);
        try {
            mScreenSaverStyle = p1;
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_Get_ScreenSaverStyle exception = " + e.getMessage());
        }
    }

    private void ack_Cam_Get_LapTracksInfo(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_Get_LapTracksInfo p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_Get_LapTracksUpdatePort(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_Get_LapTracksUpdatePort p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_Set_MountSettings(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_Set_MountSettings p1=" + p1 + ", p2=" + p2);
        getMountSettings(true);
    }

    private void ack_Cam_Set_HdrMode(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_Set_HdrMode p1=" + p1 + ", p2=" + p2);
//        try {
//            getHdrMode();
//        } catch (Exception e) {
//            Logger.t(TAG).d("ack_Cam_Set_HdrMode exception = " + e.getMessage());
//        }
    }

    private void ack_Cam_FactoryReset(String p1, String p2) {
        Logger.t(TAG).d("ack_Cam_FactoryReset p1=" + p1 + ", p2=" + p2);
    }

    private void ack_Cam_FormatSDCard(String p1) {
        Logger.t(TAG).d("ack_Cam_FormatSDCard p1=" + p1);
        int res;
        try {
            res = Integer.parseInt(p1);
            shouldFormatStorage = res <= 0;
            mRxBus.post(new FormatSDCardEvent(this, res));
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Cam_FormatSDCard exception = " + e.getMessage());
        }
    }

    private void handleRecordMessage(int cmd, String p1, String p2) {
        switch (cmd) {
            case CMD_REC_ERROR:
                ack_Rec_Error(p1, p2);
                break;
            case CMD_REC_LIST_RESOLUTIONS:
                ack_Rec_List_Resolutions(p1);
                break;
            case CMD_REC_GET_RESOLUTION:
                ack_Rec_Get_Resolution(p1);
                break;
            case CMD_REC_LIST_QUALITIES:
                ack_Rec_List_Qualities(p1, p2);
                break;
            case CMD_REC_GET_QUALITY:
                ack_Rec_Get_Quality(p1, p2);
                break;
            case CMD_REC_LIST_REC_MODES:
                ack_Rec_List_RecModes(p1);
                break;
            case CMD_REC_GET_REC_MODE:
                ack_Rec_Get_RecMode(p1);
                break;
            case CMD_REC_LIST_COLOR_MODES:
                ack_Rec_List_ColorModes(p1);
                break;
            case CMD_REC_GET_COLOR_MODE:
                ack_Rec_Get_ColorMode(p1, p2);
                break;
            case CMD_REC_GET_OVERLAY_STATE:
                ack_Rec_Get_OverlayState(p1);
                break;
            case CMD_REC_SET_OVERLAY:
                ack_Rec_Set_OverlayState(p1, p2);
                break;
            case CMD_REC_GET_MARK_TIME:
                ack_Rec_Get_MarkTime(p1, p2);
                break;
            case CMD_REC_SET_MARK_TIME:
                ack_Rec_Set_MarkTime(p1, p2);
                break;
            case CMD_REC_GET_ROTATE_MODE:
                ack_Rec_Get_RotateMode(p2);
                break;
            case CMD_REC_MARK_LIVE_VIDEO:
                ack_Rec_Mark_LiveVideo(p1);
                break;
            case CMD_REC_GET_SUB_STREAM_ONLY:
                ack_Rec_Get_StreamNum(p1, p2);
                break;
            default:
//                Logger.t(TAG).d("ack " + cmd + " not handled, p1=" + p1 + ", p2=" + p2);
                break;
        }
    }

    private void ack_Rec_Get_StreamNum(String p1, String p2) {
        Logger.t(TAG).d("ack_Rec_Get_StreamNum p1: " + p1 + " p2: " + p2);
        mSubStreamOnly = Integer.parseInt(p1) == 1;
        mRxBus.post(new StreamRecordChangeEvent(VdtCamera.this, mSubStreamOnly));
    }

    private void ack_Rec_Mark_LiveVideo(String p1) {
//        Logger.t(TAG).d("ack_Rec_Mark_LiveVideo p1=" + p1 + ", p2=" + p2);
        int i = Integer.parseInt(p1);
        mRxBus.post(new MarkLiveMsgEvent(VdtCamera.this, null, i == 0));
    }

    private void ack_Rec_Error(String p1, String p2) {
        Logger.t(TAG).d("ack_Rec_Error p1=" + p1 + ", p2=" + p2);
        int error = Integer.parseInt(p1);
        switch (error) {
            case ERROR_START_RECORD_NO_CARD:
                infoMsgQueue.putMsg(InfoMsgQueue.E_NO_SDCARD_INSERT);
                break;
            case ERROR_START_RECORD_CARD_ERROR:
                infoMsgQueue.putMsg(InfoMsgQueue.E_RECORD_ERROR);
                break;
        }
        mRxBus.post(new CameraStateChangeEvent(CameraStateChangeEvent.CAMERA_STATE_REC_ERROR, VdtCamera.this, error));
    }


    private void ack_Rec_List_Resolutions(String p1) {
//        Logger.t(TAG).d("ack_Rec_List_Resolutions p1=" + p1 + ", p2=" + p2);
        mVideoResolutionList = Integer.parseInt(p1);
    }

    private void ack_Rec_Get_Resolution(String p1) {
//        Logger.t(TAG).d("ack_Rec_Get_Resolution p1=" + p1 + ", p2=" + p2);
        mVideoResolutionIndex = Integer.parseInt(p1);
    }


    private void ack_Rec_List_Qualities(String p1, String p2) {
        Logger.t(TAG).d("ack_Rec_List_Qualities p1=" + p1 + ", p2=" + p2);
//        try {
//            int list = Integer.parseInt(p1);
//            for (int i = 0; i < 30; i++) {
//                if ((list & (0x01 << i)) != 0) {
//                    Logger.t(TAG).e("ack_Rec_List_Qualities: " + i);
//                }
//            }
//        } catch (Exception ex) {
//            ex.printStackTrace();
//        }
    }

    private void ack_Rec_Get_Quality(String p1, String p2) {
        Logger.t(TAG).d("ack_Rec_Get_Quality p1=" + p1 + ", p2=" + p2);
        mMainStreamQuality = Integer.parseInt(p1);
        mSubStreamQuality = Integer.parseInt(p2);
        mRxBus.post(new VideoQualityChangeEvent(VdtCamera.this, mMainStreamQuality, mSubStreamQuality));
    }


    private void ack_Rec_List_RecModes(String p1) {
//        Logger.t(TAG).d("ack_Rec_List_RecModes p1=" + p1 + ", p2=" + p2);
        mRecordModeList = Integer.parseInt(p1);
    }

    private void ack_Rec_Get_RecMode(String p1) {
//        Logger.t(TAG).d("ack_Rec_Get_RecMode p1=" + p1 + ", p2=" + p2);
        int index = Integer.parseInt(p1);
        if (mRecordModeIndex != index) {
            mRxBus.post(new CameraStateChangeEvent(CameraStateChangeEvent.CAMERA_STATE_REC, VdtCamera.this, null));
            mRecordModeIndex = index;
        }
    }


    private void ack_Rec_List_ColorModes(String p1) {
//        Logger.t(TAG).d("ack_Rec_List_ColorModes p1=" + p1 + ", p2=" + p2);
        mColorModeList = Integer.parseInt(p1);
    }


    private void ack_Rec_Get_ColorMode(String p1, String p2) {
        Logger.t(TAG).d("ack_Rec_Get_ColorMode p1=" + p1 + ", p2=" + p2);
        mColorModeIndex = Integer.parseInt(p1);
    }


    private void ack_Rec_Get_OverlayState(String p1) {
//        Logger.t(TAG).d("ack_Rec_Get_OverlayState p1=" + p1 + ", p2=" + p2);
        int flags = Integer.parseInt(p1);
        mOverlayFlags = 2 & flags;
    }

    private void ack_Rec_Set_OverlayState(String p1, String p2) {
        Logger.t(TAG).d("ack_Rec_Set_OverlayState p1=" + p1 + ", p2=" + p2);
        //mOverlayFlags = 2 & flags;
    }

    private void ack_Rec_Set_MarkTime(String p1, String p2) {
        Logger.t(TAG).d("ack_Rec_Set_MarkTime p1=" + p1 + ", p2=" + p2);
        try {
            mMarkBeforeTime = Integer.parseInt(p1);
            mMarkAfterTime = Integer.parseInt(p2);
        } catch (Exception e) {
            Logger.t(TAG).d("ack_Rec_Set_MarkTime exception = " + e.getMessage());
        }
    }

    private void ack_Rec_Get_RotateMode(String p2) {
//        Logger.t(TAG).d("ack_Rec_Get_RotateMode p1=" + p1 + ", p2=" + p2);
        mIfRotate = !p2.equals("normal");
    }

//    @Override
//    public void powerOff() {
//    }

//    @Override
//    public void reboot() {
//    }
}
