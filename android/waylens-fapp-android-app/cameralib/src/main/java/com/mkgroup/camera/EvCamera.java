package com.mkgroup.camera;

import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getAdasCfg;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getAuxCfg;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getHDRMode;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getMarkSettings;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getMaxMarkSpace;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getRecordConfig;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getRecordConfigList;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getState;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getVinMirror;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getMacWlan0;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getModeVision;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setMacWlan0;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setStatusIvlpr;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setModeVision;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getStatusSradar;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getStatusExboard;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setStatusExboard;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setStatusCover;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_getVirtualIgnition;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_manualMarkClip;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setAdasCfg;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setAuxCfg;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setHDRMode;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setMaxMarkSpace;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setRecordConfig;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setVinMirror;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_setVirtualIgnition;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_startRecord;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAM.CMD_CAM_stopRecord;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAT.CMD_CAT_CAMERA;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAT.CMD_CAT_DEBUG;
import static com.mkgroup.camera.command.EvCameraCmdConsts.CAT.CMD_CAT_DEVICE;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_factoryReset;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_formatTF;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getAccelDetectLevel;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getAttitude;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getAudioPrompts;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getCameraLog;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getDebugReportLog;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getDeviceInfo;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getDriveBehaviourDetect;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getHotspotInfo;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getIgnitionMode;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getLTEInformation;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getLTEStatus;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getMWSensitivity;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getMicState;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getMountSettings;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getMountVersion;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getName;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getP2PInfo;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getParkSleepDelay;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getPowerState;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getProtectionVoltage;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getServerUrl;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getSpeakerState;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getSupportWlanMode;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getTFState;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getTime;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getTrustACCStatus;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_getWiFiKey;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_removeP2PDevice;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setAPN;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setAccelDetectLevel;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setAttitude;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setAudioPrompts;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setDriveBehaviourDetectEnabled;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setDriveBehaviourDetectParams;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setHotspotInfo;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setMWSensitivity;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setMicState;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setMountSettings;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setName;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setP2PEnable;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setParkSleepDelay;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setProtectionVoltage;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setServerUrl;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setTime;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_setTrustACCStatus;
import static com.mkgroup.camera.command.EvCameraCmdConsts.DEV.CMD_DEV_transferFirmware;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_CHECK_CARRIER;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_CHECK_SIM_DATA;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_INOUT;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_MOC_CONFIG;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_MOC_INFO;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_REMOVE_FACE_DATA;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_SAVE_FACE_DATA;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_SEND_DATA_FW;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_SETTING_CFG;
import static com.mkgroup.camera.command.EvCameraCmdConsts.MK.CMD_MK_SET_DRIVER_INFO;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_AdasCfg;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_AuxCfg;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_HDRMode;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_MarkSettings;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_MaxMarkSpace;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_RecordConfig;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_RecordConfigList;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_State;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_VinMirror;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_MAC;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_SRADAR;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_MODE_VISION;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_Exboard;
import static com.mkgroup.camera.message.EvCameraMsgConsts.CAM.MSG_CAM_VirtualIgnition;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_AccelDetectLevel;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_Attitude;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_AudioPrompts;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_CameraDebugLog;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_CameraLog;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_DeviceInfo;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_DriveBehaviourDetect;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_HotspotInfo;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_IgnitionMode;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_KeepAliveForApp;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_LTEInformation;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_LTEStatus;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_MWSensitivity;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_MicState;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_MountSettings;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_MountVersion;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_Name;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_P2PInfo;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_ParkSleepDelay;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_PowerState;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_ProtectionVoltage;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_ServerUrl;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_SpeakerState;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_SupportWlanMode;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_TFState;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_Time;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_TrustACCStatus;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_WiFiKey;
import static com.mkgroup.camera.message.EvCameraMsgConsts.DEV.MSG_DEV_transferFirmware;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_CARRIER;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_DRIVER_INFO;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_INOUT;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_MOC_METHOD;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_SEND_DATA_FW;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_SEND_FACE;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_SETTING_CFG;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_SIM_DATA;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_TCVN01;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_TCVN02;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_TCVN03;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_TCVN04;
import static com.mkgroup.camera.message.EvCameraMsgConsts.MK.MSG_MK_TCVN05;

import android.util.Log;

import com.mkgroup.camera.message.bean.AccelDetectLevelBean;
import com.mkgroup.camera.message.bean.AdasCfgInfo;
import com.mkgroup.camera.message.bean.AttitudeBean;
import com.mkgroup.camera.message.bean.AuxCfgModel;
import com.mkgroup.camera.message.bean.AuxCfgSettingModel;
import com.mkgroup.camera.message.bean.CameraLogBean;
import com.mkgroup.camera.message.bean.CustomMK;
import com.mkgroup.camera.message.bean.DeviceInfoBean;
import com.mkgroup.camera.message.bean.DriveBehaviourDetectBean;
import com.mkgroup.camera.message.bean.DriverInfoBody;
import com.mkgroup.camera.message.bean.EnableBean;
import com.mkgroup.camera.message.bean.EnabledBean;
import com.mkgroup.camera.message.bean.ForceCodecBean;
import com.mkgroup.camera.message.bean.HdrModeBean;
import com.mkgroup.camera.message.bean.HotspotInfoModel;
import com.mkgroup.camera.message.bean.IgnitionModeBean;
import com.mkgroup.camera.message.bean.InoutBean;
import com.mkgroup.camera.message.bean.KeepAliveForAppBean;
import com.mkgroup.camera.message.bean.LTEInformationBean;
import com.mkgroup.camera.message.bean.LicenseBean;
import com.mkgroup.camera.message.bean.MarkSettingsBean;
import com.mkgroup.camera.message.bean.MaxMarkSpaceBean;
import com.mkgroup.camera.message.bean.ModeVisionBean;
import com.mkgroup.camera.message.bean.MountSetting;
import com.mkgroup.camera.message.bean.MwSensitivityBean;
import com.mkgroup.camera.message.bean.NameBean;
import com.mkgroup.camera.message.bean.P2PInfoBean;
import com.mkgroup.camera.message.bean.P2PPairedDevicesBean;
import com.mkgroup.camera.message.bean.ParkSleepDelayBean;
import com.mkgroup.camera.message.bean.PowerStateBean;
import com.mkgroup.camera.message.bean.ProtectionVoltageBean;
import com.mkgroup.camera.message.bean.RecordConfigBean;
import com.mkgroup.camera.message.bean.RecordConfigListBean;
import com.mkgroup.camera.message.bean.RiskyDriveEventParamsBean;
import com.mkgroup.camera.message.bean.SendIMG;
import com.mkgroup.camera.message.bean.ServerUrlBean;
import com.mkgroup.camera.message.bean.SettingCfgBean;
import com.mkgroup.camera.message.bean.StateBean;
import com.mkgroup.camera.message.bean.SupportWlanModeBean;
import com.mkgroup.camera.message.bean.TfStateBean;
import com.mkgroup.camera.message.bean.TimeBean;
import com.mkgroup.camera.message.bean.TransferFirmwareBean;
import com.mkgroup.camera.message.bean.TransferInfoBean;
import com.mkgroup.camera.message.bean.TrustACCStatusBean;
import com.mkgroup.camera.message.bean.VinMirrorBean;
import com.mkgroup.camera.message.bean.SradarBean;
import com.mkgroup.camera.message.bean.ExboardBean;
import com.mkgroup.camera.message.bean.VolumnStateBean;
import com.mkgroup.camera.message.bean.WiFiKeyBean;
import com.orhanobut.logger.Logger;
import com.mkgroup.camera.command.EvCameraCmdConsts;
import com.mkgroup.camera.direct.PairedDevices;
import com.mkgroup.camera.event.AdasCfgChangeEvent;
import com.mkgroup.camera.event.AuxCfgChangeEvent;
import com.mkgroup.camera.event.FormatSDCardEvent;
import com.mkgroup.camera.log.CmdRequestFuture;
import com.mkgroup.camera.message.EvCameraMsgConsts;
import com.mkgroup.camera.utils.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class EvCamera extends CameraWrapper implements EvCameraCmdConsts, EvCameraMsgConsts {

    private final static String TAG = EvCamera.class.getSimpleName();

    private List<RecordConfigListBean.ConfigListBean> mRecordConfigList;
    private String mCurRecordConfig;
    private String mHisRecordConfig;
    private int mForceCodec;

    private List<String> mVinMirrorList;
    private LicenseBean mMac;
    private ModeVisionBean mModeVision;
    private SradarBean Sradar;
    private ExboardBean Exboard;

    private AdasCfgInfo mAdasCfgInfo;

    private AuxCfgModel mAuxCfgModel;

    private boolean mIsFormatting;
    private String info;

    EvCamera(ServiceInfo serviceInfo, OnConnectionChangeListener listener) {
        super(serviceInfo, listener);
    }

    @Override
    public void handleMessage(int domain, int code, String p1, String p2) {
        Log.d("handleMessage","handleEvCamMessage: " + domain + " " + code + " " + p1 +" " + p2);
        //do nothing
    }

    @Override
    public void handleEvCamMessage(String category, String msg, String body) {
        Log.d("handleEvCamMessage","handleEvCamMessage: " + category + " " + msg + " " + body);
        switch (category) {
            case CMD_CAT_DEVICE:
                handleDeviceEvMessage(msg, body);
                break;
            case CMD_CAT_CAMERA:
                handleCameraEvMessage(msg, body);
                break;
            case CMD_CAT_DEBUG:
                handleCameraEvDebug(msg);
                break;
        }
    }

    private void handleDeviceEvMessage(String msg, String body) {
        switch (msg) {
            case MSG_DEV_DeviceInfo:
                DeviceInfoBean infoBean = gson.fromJson(body, DeviceInfoBean.class);
                mHardwareName = infoBean.getModel();
                mSerialNumber = infoBean.getSn();
                ack_Cam_Get_ApiVersion(infoBean.getApi());
                ack_Cam_Get_FW_Version(infoBean.getModel(), infoBean.getBuild());
                break;
            case MSG_DEV_Time:
                TimeBean timeBean = gson.fromJson(body, TimeBean.class);
                ack_Cam_Get_DeviceTime(String.valueOf(timeBean.getTime()), String.valueOf(timeBean.getGmtoff()));
                break;
            case MSG_DEV_Name:
                NameBean nameBean = gson.fromJson(body, NameBean.class);
                ack_Cam_Get_NameResult(nameBean.getName());
                break;
//            case MSG_DEV_DateTimeFormat:
//                DateTimeFormatBean formatBean = gson.fromJson(body, DateTimeFormatBean.class);
//                Logger.t(TAG).d("CMD_DEV_DateTimeFormat: " + formatBean);
//                break;
            case MSG_DEV_TFState:
                TfStateBean stateBean = gson.fromJson(body, TfStateBean.class);
                int state = STATE_STORAGE_UNKNOWN;
                switch (stateBean.getState()) {
                    case "none":
                        state = STATE_STORAGE_NO_STORAGE;
                        break;
                    case "loading":
                        state = STATE_STORAGE_LOADING;
                        break;
                    case "ready":
                        state = STATE_STORAGE_READY;
                        if (mIsFormatting) {
                            mIsFormatting = false;
                            mRxBus.post(new FormatSDCardEvent(this, 1));
                        }
                        break;
                    case "error":
                        state = STATE_STORAGE_ERROR;
                        break;
                    case "unknown":

                        break;
                    case "usbdisc":
                        state = STATE_STORAGE_USBDISC;
                        break;
                    case "formatting":
                        state = STATE_STORAGE_FORMATTING;
                        if (!mIsFormatting) {
                            mIsFormatting = true;
                        }
                        break;
                    case "unmounted":
                        state = STATE_STORAGE_UNMOUNTED;
                        break;
                }
                ack_Cam_StorageInfo(String.valueOf(state), stateBean.getSystem_id());
                break;
            case MSG_DEV_MicState:
                VolumnStateBean micBean = gson.fromJson(body, VolumnStateBean.class);
                ack_Cam_MicInfo(micBean.isMuted() ? "1" : "0", String.valueOf(micBean.getVolumn()));
                break;
            case MSG_DEV_SpeakerState:
                VolumnStateBean speakerBean = gson.fromJson(body, VolumnStateBean.class);
                ack_Cam_Get_SpeakerStatus(speakerBean.isMuted() ? "0" : "1", String.valueOf(speakerBean.getVolumn()));
                break;
//            case MSG_DEV_GPSState:
//                GpsStateBean gpsBean = gson.fromJson(body, GpsStateBean.class);
//                Logger.t(TAG).d("CMD_DEV_GPSState: " + gpsBean);
//                break;
//            case MSG_DEV_WifiInfo:
//                WifiInfoBean wifiBean = gson.fromJson(body, WifiInfoBean.class);
//                Logger.t(TAG).d("CMD_DEV_WifiInfo: " + wifiBean);
//                break;
            case MSG_DEV_transferFirmware:
                TransferInfoBean transferInfoBean = gson.fromJson(body, TransferInfoBean.class);
                ack_Cam_Get_FW_NewVersion(transferInfoBean);
                break;
//            case MSG_DEV_LCDBrightness:
//                BrightnessBean brightnessBean = gson.fromJson(body, BrightnessBean.class);
//                Logger.t(TAG).d("CMD_DEV_LCDBrightness: " + brightnessBean);
//                break;
//            case MSG_DEV_ScreenSaverTimeout:
//                ScreenSaverTimeoutBean timeoutBean = gson.fromJson(body, ScreenSaverTimeoutBean.class);
//                Logger.t(TAG).d("CMD_DEV_ScreenSaverTimeout: " + timeoutBean);
//                break;
//            case MSG_DEV_UserFileList:
//                UserFileListBean fileListBean = gson.fromJson(body, UserFileListBean.class);
//                Logger.t(TAG).d("CMD_DEV_UserFileList: " + fileListBean);
//                break;
            case MSG_DEV_AccelDetectLevel:
                AccelDetectLevelBean levelBean = gson.fromJson(body, AccelDetectLevelBean.class);
                ack_Cam_Get_MountAccelLevels(levelBean.getLevels(), levelBean.getLevel());
                break;
            case MSG_DEV_MWSensitivity:
                MwSensitivityBean sensitivityBean = gson.fromJson(body, MwSensitivityBean.class);
                ack_Cam_Get_MountSensitivity(String.valueOf(sensitivityBean.getLevel()));
                break;
//            case MSG_DEV_RiskyDriveEventEnabled:
//                EnabledBean riskyBean = gson.fromJson(body, EnabledBean.class);
//                ack_Cam_Get_SupportRiskDriveEvent(riskyBean.isEnabled() ? "1" : "0");
//                break;
//            case MSG_DEV_RiskyDriveEventParams:
//                RiskyDriveEventParamsBean paramsBean = gson.fromJson(body, RiskyDriveEventParamsBean.class);
//                ack_Cam_Get_EventDetectionParam(paramsBean.getParam().toString());
//                break;
//            case MSG_DEV_P2PEnable:
//                EnabledBean p2pBean = gson.fromJson(body, EnabledBean.class);
//                ack_Cam_Get_P2P_Enable(p2pBean.isEnabled() ? "1" : "0");
//                break;
//            case MSG_DEV_P2PPairedDevices:
////                P2PPairedDevicesBean pairedBean = gson.fromJson(body, P2PPairedDevicesBean.class);
//                ack_Cam_Get_P2P_PairedList(body);
//                break;
            case MSG_DEV_DriveBehaviourDetect:
                DriveBehaviourDetectBean detectBean = gson.fromJson(body, DriveBehaviourDetectBean.class);
                ack_Cam_Get_SupportRiskDriveEvent(detectBean.isEnabled() ? "1" : "0");
                ack_Cam_Get_EventDetectionParam(detectBean.getParam().toString());
                break;
            case MSG_DEV_P2PInfo:
                P2PInfoBean p2PInfoBean = gson.fromJson(body, P2PInfoBean.class);
                ack_Cam_Get_P2P_Enable(p2PInfoBean.isEnabled() ? "1" : "0");
                ack_Cam_Get_P2P_PairedList(body);
                break;
            case MSG_DEV_SupportWlanMode:
                SupportWlanModeBean modeBean = gson.fromJson(body, SupportWlanModeBean.class);
                ack_Cam_SupportWlanMode(modeBean.isSupported() ? "1" : "0");
                break;
            case MSG_DEV_TrustACCStatus:
                TrustACCStatusBean trustBean = gson.fromJson(body, TrustACCStatusBean.class);
                ack_Cam_Get_MountAccTrust(trustBean.isTrust() ? "1" : "0");
                break;
            case MSG_DEV_AudioPrompts:
                EnabledBean audioBean = gson.fromJson(body, EnabledBean.class);
                ack_Cam_Get_AudioPrompts(audioBean.isEnabled() ? "on" : "off");
                break;
            case MSG_DEV_KeepAliveForApp:
                KeepAliveForAppBean aliveBean = gson.fromJson(body, KeepAliveForAppBean.class);
                Logger.t(TAG).d("CMD_DEV_KeepAliveForApp: " + aliveBean);
                break;
            case MSG_DEV_Attitude:
                AttitudeBean attitudeBean = gson.fromJson(body, AttitudeBean.class);
                ack_Cam_Support_Upsidedown(attitudeBean.isIsConfigurable() ? "1" : "0");
                ack_Cam_Get_Attitude(attitudeBean.getAttitude());
                break;
            case MSG_DEV_ProtectionVoltage:
                ProtectionVoltageBean voltageBean = gson.fromJson(body, ProtectionVoltageBean.class);
                ack_Cam_Get_ProtectionVoltage(String.valueOf(voltageBean.getMv()));
                break;
            case MSG_DEV_ParkSleepDelay:
                ParkSleepDelayBean delayBean = gson.fromJson(body, ParkSleepDelayBean.class);
                ack_Cam_Get_ParkSleepDelay(String.valueOf(delayBean.getDelayInSec()));
                break;
            case MSG_DEV_LTEInformation:
                LTEInformationBean lteBean = gson.fromJson(body, LTEInformationBean.class);
                ack_Cam_Get_Iccid(lteBean.getIccid());
                ack_Cam_Get_LteVertion(lteBean.getVersion(), lteBean.getVersion_internal());
                ack_Cam_Get_APN(lteBean.getApn());
                break;
            case MSG_DEV_LTEStatus:
//                LTEStatusBean statusBean = gson.fromJson(body, LTEStatusBean.class);
                ack_Cam_Get_LteStatus(body);
                break;
            case MSG_DEV_CameraLog:
            case MSG_DEV_CameraDebugLog:
                CameraLogBean logBean = gson.fromJson(body, CameraLogBean.class);
                ack_Cam_CopyLog(String.valueOf(logBean.getReady()));
                break;
            case MSG_DEV_WiFiKey:
                WiFiKeyBean wiFiKeyBean = gson.fromJson(body, WiFiKeyBean.class);
                ack_Cam_FW_Get_Key(wiFiKeyBean.getKey());
                break;
            case MSG_DEV_ServerUrl:
                ServerUrlBean urlBean = gson.fromJson(body, ServerUrlBean.class);
                ack_Cam_Get_Server(urlBean.getUrl());
                break;
            case MSG_DEV_MountVersion:
//                MountVersionBean versionBean = gson.fromJson(body, MountVersionBean.class);
                ack_Cam_Get_MountVersion(body);
                break;
            case MSG_DEV_MountSettings:
//                MountSettingsBean settingsBean = gson.fromJson(body, MountSettingsBean.class);
                ack_Cam_Get_MountSettings(body);
                break;
            case MSG_DEV_IgnitionMode:
                IgnitionModeBean ignitionModeBean = gson.fromJson(body, IgnitionModeBean.class);
                ack_Cam_Get_MonitorMode(ignitionModeBean.getMode());
                break;
            case MSG_DEV_PowerState:
                PowerStateBean powerBean = gson.fromJson(body, PowerStateBean.class);
                ack_Dev_PowerState(powerBean);
                break;
            case MSG_DEV_HotspotInfo:
//                HotspotInfoModel model = gson.fromJson(body, HotspotInfoModel.class);
                ack_Dev_HotspotInfo(body);
                break;
        }
    }

    private void ack_Cam_Get_FW_NewVersion(TransferInfoBean bean) {
//        Logger.t(TAG).d("ack_Cam_Get_FW_NewVersion: " + bean);
        if (mOnNewFwVersionListener != null) {
            mOnNewFwVersionListener.onTransfer(bean);
        }
    }

    private void handleCameraEvDebug(String info) {
        Logger.t(TAG).d("handleCameraEvDebug: " + info);
    }

    private void handleCameraEvMessage(String msg, String body) {
        switch (msg) {
            //mk
            /*case MSG_MK_SAVE_FACE_DATA:
                ack_MK_Save_Data(body);
                break;*/
            case MSG_MK_MOC_METHOD:
                ack_MK_MOC(body);
                break;
            case MSG_MK_SEND_DATA_FW:
                ack_MK_Send_Data_FW(body);
                break;
            case MSG_MK_CARRIER:
                ack_MK_Carrier(body);
                break;
            case MSG_MK_SIM_DATA:
                ack_MK_SIM_DATA(body);
                break;
            case MSG_MK_SEND_FACE:
                ack_MK_SEND_FACE(body);
                break;
            case MSG_MK_TCVN01:
                ack_MK_01(body);
                break;
            case MSG_MK_TCVN02:
                ack_MK_02(body);
                break;
            case MSG_MK_TCVN03:
                ack_MK_03(body);
                break;
            case MSG_MK_TCVN04:
                ack_MK_04(body);
                break;
            case MSG_MK_TCVN05:
                ack_MK_05(body);
                break;
            case MSG_MK_DRIVER_INFO:
                ack_MK_driverInfo(body);
                break;
            case MSG_MK_SETTING_CFG:
                ack_MK_settingCfg(body);
                break;
            case MSG_MK_INOUT:
                ack_MK_INOUT(body);
                break;
            //end
            case MSG_CAM_RecordConfigList:
                RecordConfigListBean listBean = gson.fromJson(body, RecordConfigListBean.class);
                msg_cam_getRecordConfigList(listBean);
//                Logger.t(TAG).d("MSG_CAM_RecordConfigList: " + listBean);
                break;
            case MSG_CAM_RecordConfig:
                RecordConfigBean configBean = gson.fromJson(body, RecordConfigBean.class);
                msg_cam_get_recodConfig(configBean);
//                Logger.t(TAG).d("MSG_CAM_RecordConfig: " + configBean);
                break;
//            case MSG_CAM_RecordMode:
//                RecordModeBean modeBean = gson.fromJson(body, RecordModeBean.class);
//                Logger.t(TAG).d("MSG_CAM_RecordMode: " + modeBean);
//                break;
//            case MSG_CAM_VideoOverlay:
//                VideoOverlayBean overlayBean = gson.fromJson(body, VideoOverlayBean.class);
//                Logger.t(TAG).d("MSG_CAM_VideoOverlay: " + overlayBean);
//                break;
            case MSG_CAM_State:
                StateBean stateBean = gson.fromJson(body, StateBean.class);
                int state = STATE_RECORD_UNKNOWN;
                switch (stateBean.getState()) {
                    case "stopped":
                        state = STATE_RECORD_STOPPED;
                        break;
                    case "stopping":
                        state = STATE_RECORD_STOPPING;
                        break;
                    case "starting":
                        state = STATE_RECORD_STARTING;
                        break;
                    case "recording":
                        state = STATE_RECORD_RECORDING;
                        break;
                    case "closed":
                        state = STATE_RECORD_CLOSED;
                        break;
                    case "opening":
                        state = STATE_RECORD_OPENING;
                        break;
                    case "error":
                        state = STATE_RECORD_ERROR;
                        break;
                    case "switching":
                        state = STATE_RECORD_SWITCHING;
                        break;
                }
                ack_Cam_Get_StateResult(String.valueOf(state));
                break;
//            case MSG_CAM_MarkState:
//                MarkStateBean markBean = gson.fromJson(body, MarkStateBean.class);
//                Logger.t(TAG).d("MSG_CAM_MarkState: " + markBean);
//                break;
//            case MSG_CAM_StorageSpaceInfo:
//                StorageSpaceInfoBean infoBean = gson.fromJson(body, StorageSpaceInfoBean.class);
//                Logger.t(TAG).d("MSG_CAM_StorageSpaceInfo: " + infoBean);
//                break;
            case MSG_CAM_MarkSettings:
                MarkSettingsBean settingsBean = gson.fromJson(body, MarkSettingsBean.class);
                ack_Rec_Get_MarkTime(String.valueOf(settingsBean.getManualBefore()), String.valueOf(settingsBean.getManualAfter()));
                break;
            case MSG_CAM_VinMirror:
                VinMirrorBean mirrorBean = gson.fromJson(body, VinMirrorBean.class);
                msg_cam_vinMirror(mirrorBean);
                break;
            case MSG_CAM_MAC:
                Logger.t(TAG).d("getMAC body: " + body);
                LicenseBean macBean = gson.fromJson(body, LicenseBean.class);
                msg_cam_Mac(macBean);
                break;
            case MSG_CAM_SRADAR:
                SradarBean macSradar = gson.fromJson(body, SradarBean.class);
                msg_cam_Sradar(macSradar);
                break;
            case MSG_CAM_MODE_VISION:
                ModeVisionBean modeVisionBean = gson.fromJson(body, ModeVisionBean.class);
                msg_cam_ModeVision(modeVisionBean);
                break;
            case MSG_CAM_Exboard:
                Logger.t(TAG).d("getMAC body: " + body);
                ExboardBean exboard = gson.fromJson(body, ExboardBean.class);
                msg_cam_ExBoard(exboard);
                break;
            case MSG_CAM_HDRMode:
                HdrModeBean hdrModeBean = gson.fromJson(body, HdrModeBean.class);
                ack_Cam_Get_HdrMode(hdrModeBean.getMode());
                break;
            case MSG_CAM_MaxMarkSpace:
                MaxMarkSpaceBean spaceBean = gson.fromJson(body, MaxMarkSpaceBean.class);
                ack_Cam_Get_MarkStorage(String.valueOf(spaceBean.getMax()), spaceBean.getList().toString());
                break;
            case MSG_CAM_VirtualIgnition:
                EnableBean enableBean = gson.fromJson(body, EnableBean.class);
                ack_Cam_Get_VirtualIgnition(enableBean.isEnable());
                break;
            case MSG_CAM_AdasCfg:
                AdasCfgInfo model = gson.fromJson(body, AdasCfgInfo.class);
                ack_Cam_AdasCfgInfo(model);
                break;
            case MSG_CAM_AuxCfg:
                AuxCfgModel auxCfgModel = gson.fromJson(body, AuxCfgModel.class);
                ack_Cam_AuxCfgInfo(auxCfgModel);
                break;
        }
    }

    private void ack_Cam_AuxCfgInfo(AuxCfgModel model) {
        Logger.t(TAG).i("ack_Cam_AuxCfgInfo: " + model);
        this.mAuxCfgModel = model;
        mRxBus.post(new AuxCfgChangeEvent(this, model));
    }

    private void ack_Cam_AdasCfgInfo(AdasCfgInfo model) {
        Logger.t(TAG).i("ack_Cam_AdasCfgInfo: " + model);
        this.mAdasCfgInfo = model;
        mRxBus.post(new AdasCfgChangeEvent(this, model));
    }

    private void msg_cam_getRecordConfigList(RecordConfigListBean listBean) {
        this.mRecordConfigList = listBean.getRecordConfigList();
    }

    private void msg_cam_get_recodConfig(RecordConfigBean configBean) {
//        Logger.t(TAG).d("test msg_cam_get_recodConfig: " + configBean.toString());
        mCurRecordConfig = configBean.getRecordConfig();
        mForceCodec = configBean.getForceCodec();
    }

    private void msg_cam_vinMirror(VinMirrorBean mirrorBean) {
        this.mVinMirrorList = mirrorBean.getVinMirrorList();
    }

    private void msg_cam_Mac(LicenseBean macBean) {
        this.mMac = macBean;
    }

    private void msg_cam_Sradar(SradarBean macSradar) {
        this.Sradar = macSradar ;
    }

    private void msg_cam_ModeVision(ModeVisionBean modeVisionBean) {
        this.mModeVision = modeVisionBean ;
    }

    private void msg_cam_ExBoard(ExboardBean ExBoard) {
        this.Exboard = ExBoard ;
    }


    @Override
    public void initCameraState() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getDeviceInfo, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getName, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getMicState, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getSpeakerState, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getAccelDetectLevel, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getDriveBehaviourDetect, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getP2PInfo, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getSupportWlanMode, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getTrustACCStatus, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getAudioPrompts, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getAttitude, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getProtectionVoltage, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getParkSleepDelay, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getLTEInformation, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getLTEStatus, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getWiFiKey, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getServerUrl, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getMountVersion, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getPowerState, "");

        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getRecordConfigList, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getRecordConfig, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getState, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getMarkSettings, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getVinMirror, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getMacWlan0, "");

        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getStatusSradar, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getMaxMarkSpace, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getVirtualIgnition, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getAdasCfg, "");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getAuxCfg, "");
    }

//    @Override
//    public void doBtUnbind(int type, String mac) {
//    }

//    @Override
//    public void doBind(int type, String mac) {
//    }

    @Override
    public String getName() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getName, "");
        return mCameraName;
    }

    @Override
    public void setName(String name) {
        mCameraName = name;
        NameBean bean = new NameBean(name);
        Logger.t(TAG).d("CMD_DEV_setName: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setName, gson.toJson(bean));
    }

    @Override
    public String getApiVersion() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getDeviceInfo, "");
        return mApiVersionStr;
    }

    @Override
    public String getPassword() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getWiFiKey, "");
        return mPassword;
    }

    @Override
    public String getCameraServer() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getServerUrl, "");
        return mCameraServer;
    }

    @Override
    public void setCameraServer(String server) {
        mCameraServer = server;
        ServerUrlBean bean = new ServerUrlBean(server);
        Logger.t(TAG).d("CMD_DEV_setServerUrl: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setServerUrl, gson.toJson(bean));
    }


    @Override
    public CmdRequestFuture<Integer> prepareLog() {
        CmdRequestFuture<Integer> future = CmdRequestFuture.newFuture();
        prepareLogFuture = future;
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getCameraLog, "");
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

    @Override
    public CmdRequestFuture<Integer> prepareDebugLog() {
        CmdRequestFuture<Integer> future = CmdRequestFuture.newFuture();
        prepareLogFuture = future;
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getDebugReportLog, "");
        return future;
    }

    @Override
    public void queryStorageState() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getTFState, "");
    }

    @Override
    public int getMonitorMode() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getIgnitionMode, "");
        return monitorMode;
    }

    @Override
    public void factoryReset() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_factoryReset, "");
    }

    @Override
    public void setMicEnabled(boolean enabled) {
//        Logger.t(TAG).d("setMicEnabled: " + enabled);
        VolumnStateBean bean = new VolumnStateBean(!enabled, mMicVol);
        Logger.t(TAG).d("CMD_DEV_setMicState: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setMicState, gson.toJson(bean));
    }

    @Override
    public void setAudioPromptsEnabled(boolean enabled) {
//        Logger.t(TAG).d("setAudioPromptsEnabled: " + enabled);
        EnabledBean bean = new EnabledBean(enabled);
        Logger.t(TAG).d("CMD_DEV_setAudioPrompts: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setAudioPrompts, gson.toJson(bean));
    }

    @Override
    public void setLensNormal(boolean isNormal) {
        String attitude = isNormal ? LENS_NORMAL : LENS_UPSIDEDOWN;
        AttitudeBean bean = new AttitudeBean(attitude);
        Logger.t(TAG).d("CMD_DEV_setAttitude: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setAttitude, gson.toJson(bean));
    }

    @Override
    public void removePaired(String mac) {
        P2PPairedDevicesBean bean = new P2PPairedDevicesBean(mac.trim());
        Logger.t(TAG).d("CMD_DEV_removeP2PDevice: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_removeP2PDevice, gson.toJson(bean));
    }

    @Override
    public void sendNewFirmware(int size, String md5, OnNewFwVersionListener listener) {
        mOnNewFwVersionListener = listener;
        TransferFirmwareBean bean = new TransferFirmwareBean(size, md5, true);
        Logger.t(TAG).d("CMD_DEV_transferFirmware: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_transferFirmware, gson.toJson(bean));
    }

    @Override
    public MountSetting getMountSettings(boolean refresh) {
        if (refresh)
            mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getMountSettings, "");
        return mountSetting;
    }

    @Override
    public void setMountSettings(String setting) {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setMountSettings, setting);
    }

    @Override
    public int getHdrMode() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getHDRMode, "");
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
        HdrModeBean bean = new HdrModeBean(mode);
        Logger.t(TAG).d("CMD_CAM_setHDRMode: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setHDRMode, gson.toJson(bean));
    }

    @Override
    public void sendFormatSDCard() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_formatTF, "");
    }

    @Override
    public void markLiveVideo() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_manualMarkClip, "");
    }

//    @Override
//    public void setMarkTime(int before, int after) {
//        if (before < 0 || after < 0) {
//            return;
//        }
//        MarkSettingsBean bean = new MarkSettingsBean(before, after, true);
//        Logger.t(TAG).d("CMD_CAM_setManualMarkSettings: " + gson.toJson(bean));
//        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setManualMarkSettings, gson.toJson(bean));
//    }

    @Override
    public void stopRecording() {
        Logger.t(TAG).i("stopRecording");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_stopRecord, "");
    }

    @Override
    public void startRecording() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_startRecord, "");
    }

    @Override
    public boolean isPromptsEnabled() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getAudioPrompts, "");
        return mPromptsState == AUDIO_PROMPTS_MODE_ON;
    }

    @Override
    public int getRadarSensitivity() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getMWSensitivity, "");
        return mRadarSensitivity;
    }

    @Override
    public void setRadarSensitivity(int sensitivity) {
        mRadarSensitivity = sensitivity;
        MwSensitivityBean bean = new MwSensitivityBean(sensitivity);
        Logger.t(TAG).d("CMD_DEV_setMWSensitivity: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setMWSensitivity, gson.toJson(bean));
    }

    @Override
    public int getMountAccTrust() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getTrustACCStatus, "");
        return mMountAccTrust;
    }

    @Override
    public void setMountAccTrust(boolean trust) {
        TrustACCStatusBean bean = new TrustACCStatusBean(trust);
        Logger.t(TAG).d("CMD_DEV_setTrustACCStatus: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setTrustACCStatus, gson.toJson(bean));
    }

    @Override
    public boolean getP2pEnable() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getP2PInfo, "");
        return mP2pEnable;
    }

    @Override
    public void setP2pEnable(boolean enable) {
        EnabledBean bean = new EnabledBean(enable);
        Logger.t(TAG).d("CMD_DEV_setP2PEnable: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setP2PEnable, gson.toJson(bean));
    }

    @Override
    public PairedDevices getPairedDevices() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getP2PInfo, "");
        return pairedDevices;
    }

    @Override
    public boolean getIsLensNormal() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getAttitude, "");
        return mIsLensNormal;
    }

    @Override
    public String getApnSetting() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getLTEInformation, "");
        return mApnSetting;
    }

    @Override
    public void setApnSetting(String apn) {
        mApnSetting = apn;
        LTEInformationBean bean = new LTEInformationBean(apn);
        Logger.t(TAG).d("CMD_DEV_setAPN: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setAPN, gson.toJson(bean));
    }

    @Override
    public boolean getSupportWlan() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getSupportWlanMode, "");
        return mSupportWlan;
    }

    @Override
    public boolean getSupportRiskEvent() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getDriveBehaviourDetect, "");
        return mSupportRiskEvent;
    }

    @Override
    public void setSupportRiskEvent(boolean support) {
        mSupportRiskEvent = support;
        EnabledBean bean = new EnabledBean(support);
        Logger.t(TAG).d("CMD_DEV_setDriveBehaviourDetectEnabled: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setDriveBehaviourDetectEnabled, gson.toJson(bean));
    }

    @Override
    public String getEventParam() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getDriveBehaviourDetect, "");
        return mEventParam;
    }

    @Override
    public void setEventParam(String param) {
        mEventParam = param;
        RiskyDriveEventParamsBean bean = new RiskyDriveEventParamsBean(StringUtils.filterArray(param));
        Logger.t(TAG).d("CMD_DEV_setDriveBehaviourDetectParams: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setDriveBehaviourDetectParams, gson.toJson(bean));
    }


    @Override
    public int getProtectVoltage() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getProtectionVoltage, "");
        return mProtectVoltage;
    }

    @Override
    public void setProtectVoltage(int voltage) {
        mProtectVoltage = voltage;
        ProtectionVoltageBean bean = new ProtectionVoltageBean(voltage);
        Logger.t(TAG).d("CMD_DEV_setProtectionVoltage: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setProtectionVoltage, gson.toJson(bean));
    }

    @Override
    public int getParkSleepDelay() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getParkSleepDelay, "");
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
        ParkSleepDelayBean bean = new ParkSleepDelayBean(time);
        Logger.t(TAG).d("CMD_DEV_setParkSleepDelay: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setParkSleepDelay, gson.toJson(bean));
    }

    @Override
    public String getModemVersion() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getLTEInformation, "");
        return modemVersion;
    }

    @Override
    public int getMarkStorage() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getMaxMarkSpace, "");
        return mVideoSpace;
    }

    @Override
    public void setMarkStorage(int index) {
        if (videoSpaceList != null && index < videoSpaceList.length) {
            mVideoSpace = index;
            MaxMarkSpaceBean bean = new MaxMarkSpaceBean(Integer.valueOf(videoSpaceList[index]));
            Logger.t(TAG).d("CMD_CAM_setMaxMarkSpace: " + gson.toJson(bean));
            mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setMaxMarkSpace, gson.toJson(bean));
        }
    }

    @Override
    public int getMountLevel() {
//            mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getAccelDetectLevel, "");
        return mMountLevel;
    }

    @Override
    public void setMountLevel(int index) {
        mMountLevel = index;

        AccelDetectLevelBean bean = new AccelDetectLevelBean(index == -1 ? "customized" : mountLevelList[index]);
        Logger.t(TAG).d("CMD_DEV_setAccelDetectLevel: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setAccelDetectLevel, gson.toJson(bean));
    }

    @Override
    public String getBspFirmware() {
        return mBspVersion;
    }

    @Override
    public int getWifiMode() {
        return mWifiMode;
    }

    @Override
    public String getIccid() {
        return mIccid;
    }

    @Override
    public void getDeviceTime() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getTime, "");
    }

    @Override
    public void setDeviceTime(long syncTime, long syncTimeZone) {
        TimeBean bean = new TimeBean(syncTime, syncTimeZone * 3600);
        Logger.t(TAG).d("CMD_DEV_setTime: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setTime, gson.toJson(bean));
    }

    @Override
    public void getMountSensitivity() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getMWSensitivity, "");
    }

    @Override
    public HotspotInfoModel getHotspotInfo() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_getHotspotInfo, "");
        return hotspotInfoModel;
    }

    @Override
    public void setHotspotInfo(String ssid, String key) {
        HotspotInfoModel model = new HotspotInfoModel(ssid, key);
        Logger.t(TAG).i("CMD_DEV_setHotspotInfo: " + gson.toJson(model));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_DEVICE, CMD_DEV_setHotspotInfo, gson.toJson(model));
    }

    @Override
    public int getVirtualIgnition() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getVirtualIgnition, "");
        return mVirtualIgnitionEnable;
    }

    @Override
    public void setVirtualIgnition(boolean enable) {
        EnableBean model = new EnableBean(enable);
        Logger.t(TAG).i("setVirtualIgnition: " + gson.toJson(model));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setVirtualIgnition, gson.toJson(model));
    }

    @Override
    public AuxCfgModel getAuxCfg() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getAuxCfg, "");
        return mAuxCfgModel;
    }

    @Override
    public void setAuxCfg(AuxCfgModel model, int angle) {
        AuxCfgSettingModel settingModel = new AuxCfgSettingModel(model, angle);
        Logger.t(TAG).i("setAuxCfg: " + gson.toJson(settingModel));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setAuxCfg, gson.toJson(settingModel));
    }

    @Override
    public boolean isNightVisionInDrivingAvailable() {
        return true;
    }

    @Override
    public boolean isPowerCordTestAvailable() {
        return true;
    }

    @Override
    public boolean isMarkSpaceSettingsAvailable() {
        return true;
    }

    @Override
    public boolean isAudioPromptsAvailable() {
        return true;
    }

    @Override
    public boolean isModemVersionAvailable() {
        return true;
    }

    @Override
    public boolean isNetworkTestDiagnosisAvailable() {
        return true;
    }

    @Override
    public boolean isHDRAutoAvailable() {
        return false;
    }

    @Override
    public boolean isNightVisionAutoAvailable() {
        return false;
    }

    @Override
    public boolean isSupportUntrustACCWireAvailable() {
        return true;
    }

    @Override
    public boolean isWifiDirectAvailable() {
        return true;
    }

    @Override
    public boolean isDrivingModeTimeoutSettingsAvailable() {
        return compareToApiVersion("1.2.01") >= 0;
    }

    @Override
    public boolean isProtectionVoltageAvailable() {
        return compareToApiVersion("1.2.01") >= 0;
    }

    @Override
    public boolean isAPNSettingsAvailable() {
        return compareToApiVersion("1.2.01") >= 0;
    }

    @Override
    public boolean isSubStreamOnlyAvailable() {
        return false;
    }

    @Override
    public boolean isWLanModeAvailable() {
        return false;
    }

    @Override
    public boolean isRiskyDrivingEventAvailable() {
        return true;
    }

    @Override
    public boolean isVinMirrorAvailable() {
        return true;
    }

    @Override
    public boolean isMacWlan0Available() {
        return true;
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
        return true;
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
        return true;
    }

    @Override
    public boolean isAuxCfgAvailable() {
        return compareToApiVersion("1.21.0") >= 0;
    }

    public List<RecordConfigListBean.ConfigListBean> getRecordConfigList() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getRecordConfigList, "");
        return mRecordConfigList;
    }

    public SradarBean getStatusSradar() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getStatusSradar, "");
        return Sradar;
    }

    public ExboardBean getStatusExboard() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getStatusExboard, "");
        return Exboard;
    }


    public int getForceCodec() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getRecordConfig, "");
        return mForceCodec;
    }

    public void setForceCodec(int forceCodec) {
        ForceCodecBean bean = new ForceCodecBean(forceCodec);
        Logger.t(TAG).d("CMD_CAM_setRecordConfig: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setRecordConfig, gson.toJson(bean));
    }

    public String getCurRecordConfig() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getRecordConfig, "");
        return mCurRecordConfig;
    }

    public void setCurRecordConfig(int configIndex) {
        RecordConfigListBean.ConfigListBean listBean = mRecordConfigList.get(configIndex);
        RecordConfigBean bean = new RecordConfigBean(listBean.getName());
        Logger.t(TAG).d("CMD_CAM_setRecordConfig: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setRecordConfig, gson.toJson(bean));
    }

    public String getHistoryRecordConfig() {
        Logger.t(TAG).d("test getHistoryRecordConfig: " + mHisRecordConfig);
        return mHisRecordConfig;
    }

    public void setHistoryRecordConfig(int configIndex) {
        Logger.t(TAG).d("test setHistoryRecordConfig: " + configIndex);
        this.mHisRecordConfig = mRecordConfigList.get(configIndex).getName();
        Logger.t(TAG).d("test mHisRecordConfig: " + mHisRecordConfig);
    }

    public List<String> getVinMirrorList() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getVinMirror, "");
        return mVinMirrorList;
    }

    public LicenseBean getMAC() {
          mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getMacWlan0, "");
        return mMac;
    }


    public ModeVisionBean getModeVision() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getModeVision, "");
        return mModeVision;
    }

    public void setMAC(LicenseBean licenseData) {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setMacWlan0, gson.toJson(licenseData));
    }

    public void setStatusIvlpr(List<LicenseBean.Algorithm> licenseList) {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setStatusIvlpr, gson.toJson(info));
    }

    public void setModeVision(ModeVisionBean info) {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setModeVision, gson.toJson(info));
    }

    public void setModeVisionsss( ) {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setModeVision, "");
    }

//    public SradarBean getStatusSradar() {
//        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getStatusSradar, "");
//        return Sradar;
//    }

    public void setStatusCover(String info) {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setStatusCover, info  );
    }

    public void setStatusExboard(String info) {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setStatusExboard, info  );
    }


    public void setVinMirrorList(List<String> vinMirrorList) {
        VinMirrorBean bean = new VinMirrorBean(vinMirrorList);
        Logger.t(TAG).d("CMD_CAM_setVinMirror: " + gson.toJson(bean));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setVinMirror, gson.toJson(bean));
    }

    public AdasCfgInfo getAdasCfgInfo() {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_getAdasCfg, "");
        return mAdasCfgInfo;
    }

    public void setAdasCfgInfo(AdasCfgInfo info) {
        Logger.t(TAG).i("setAdasCfgInfo: " + gson.toJson(info));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_CAM_setAdasCfg, gson.toJson(info));
    }

    //mk modify
    public void setAdasCfgInfoWithMK(CustomMK info, String cmd) {
        Logger.t(TAG).i("setAdasCfgInfo: " + gson.toJson(info));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, cmd, gson.toJson(info));
    }

    public void sendWithMK(CustomMK info, String cmd) {
        Logger.t(TAG).i("setAdasCfgInfo: " + gson.toJson(info));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, cmd, gson.toJson(info));
    }

    public void sendImageWithMK(SendIMG img, String cmd) {
        Logger.t(TAG).i("setAdasCfgInfo: " + gson.toJson(img));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, cmd, gson.toJson(img));
    }

    public void setDriverInfoWithMK(DriverInfoBody info) {
        Logger.t(TAG).i("setDriverInfo: " + gson.toJson(info));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_MK_SET_DRIVER_INFO, gson.toJson(info));
    }

    public void settingCfgWithMK(SettingCfgBean info) {
        Logger.t(TAG).i("settingCfg: " + gson.toJson(info));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_MK_SETTING_CFG, gson.toJson(info));
    }

    public void login_outCamera(InoutBean info) {
        Logger.t(TAG).i("login_logout: " + gson.toJson(info));
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_MK_INOUT, gson.toJson(info));
    }

    public void checkLogin(CustomMK info) {
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_MK_INOUT, gson.toJson(info));
    }

    public void checkSimData(String phone, String msg) {
        Logger.t(TAG).i("checkSimData: %s -%s", phone, msg);
        Map<String, String> params = new HashMap<>();
        params.put("phoneNo", phone);
        params.put("msg", msg);
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_MK_CHECK_SIM_DATA, gson.toJson(params));
    }

    public void checkCarrier() {
        Map<String, String> params = new HashMap<>();
        params.put("value", "checkCarrier");
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_MK_CHECK_CARRIER, gson.toJson(params));
    }

    public void saveFaceData(String faceId, String cccd) {
        Map<String, String> params = new HashMap<>();
        params.put("faceId", faceId);
        params.put("cccd", cccd);

        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_MK_SAVE_FACE_DATA, gson.toJson(params));
    }

    public void sendDataFW(String object,String url) {
        Map<String, String> params = new HashMap<>();
        params.put("content", object);
        params.put("url", url);

        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_MK_SEND_DATA_FW, gson.toJson(params));
    }

    public void removeFaceData(String faceId) {
        Map<String, String> params = new HashMap<>();
        params.put("faceId", faceId);

        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA, CMD_MK_REMOVE_FACE_DATA, gson.toJson(params));
    }

    public void configMOC(boolean isMobile){
        String mocKey = isMobile ? "mobile" : "auto";
        Map<String,String> params = new HashMap<>();
        params.put("MOC",mocKey);

        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA,CMD_MK_MOC_CONFIG,gson.toJson(params));
    }

    public void getMOC(){
        mCommunicationBus.sendEvCamCommand(CMD_CAT_CAMERA,CMD_MK_MOC_INFO,"");
    }
}
