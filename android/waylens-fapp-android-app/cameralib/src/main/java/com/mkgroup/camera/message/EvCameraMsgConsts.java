package com.mkgroup.camera.message;

public interface EvCameraMsgConsts {

    //device
    interface DEV {
        String MSG_DEV_DeviceInfo = "deviceInfo";

        String MSG_DEV_Time = "time";

//        String MSG_DEV_syncTime = "syncTime";

        String MSG_DEV_Name = "name";

//        String MSG_DEV_DateTimeFormat = "dateTimeFormat";

        String MSG_DEV_TFState = "TFState";

//        String MSG_DEV_unmountTF = "unmountTF";

        String MSG_DEV_MicState = "micState";

        String MSG_DEV_SpeakerState = "speakerState";

//        String MSG_DEV_GPSState = "GPSState";

//        String MSG_DEV_WifiInfo = "wifiInfo";

        String MSG_DEV_transferFirmware = "transferFirmware";

//        String MSG_DEV_LCDBrightness = "LCDBrightness";

//        String MSG_DEV_ScreenSaverTimeout = "screenSaverTimeout";

//        String MSG_DEV_getGsensorSensitivity = "getGsensorSensitivity";

//        String MSG_DEV_transferFile = "transferFile";

//        String MSG_DEV_UserFileList = "userFileList";

//        String MSG_DEV_playFile = "playFile";

//        String MSG_DEV_displayFile = "displayFile";

        String MSG_DEV_AccelDetectLevel = "accelDetectLevel";

        String MSG_DEV_MWSensitivity = "mwSensitivity";

        String MSG_DEV_DriveBehaviourDetect = "driveBehaviourDetect";

        String MSG_DEV_P2PInfo = "p2pInfo";

        String MSG_DEV_SupportWlanMode = "supportWlanMode";

        String MSG_DEV_TrustACCStatus = "trustACCStatus";

        String MSG_DEV_AudioPrompts = "audioPrompts";

        String MSG_DEV_KeepAliveForApp = "keepAliveForApp";

        String MSG_DEV_Attitude = "attitude";

        String MSG_DEV_ProtectionVoltage = "protectionVoltage";

        String MSG_DEV_ParkSleepDelay = "parkSleepDelay";

        String MSG_DEV_LTEInformation = "LTEInformation";

        String MSG_DEV_LTEStatus = "LTEStatus";

        String MSG_DEV_CameraLog = "cameraLog";
        String MSG_DEV_CameraDebugLog = "cameraDebugLog";

        String MSG_DEV_WiFiKey = "WiFiKey";

        String MSG_DEV_ServerUrl = "serverUrl";

        String MSG_DEV_MountVersion = "mountVersion";

        String MSG_DEV_MountSettings = "mountSettings";

        String MSG_DEV_IgnitionMode = "ignitionMode";

        String MSG_DEV_PowerState = "powerState";

        String MSG_DEV_HotspotInfo = "hotspotInfo";
    }

    //camera
    interface CAM {

        String MSG_CAM_RecordConfigList = "recordConfigList";

        String MSG_CAM_RecordConfig = "recordConfig";

//        String MSG_CAM_RecordMode = "recordMode";

//        String MSG_CAM_VideoOverlay = "videoOverlay";

        String MSG_CAM_State = "state";

//        String MSG_CAM_MarkState = "markState";

//        String MSG_CAM_StorageSpaceInfo = "storageSpaceInfo";

        String MSG_CAM_MarkSettings = "markSettings";
//        String MSG_CAM_setGsensorMarkSettings = "setGsensorMarkSettings";
//        String MSG_CAM_setManualMarkSettings = "setManualMarkSettings";

//        String MSG_CAM_startRecord = "startRecord";
//        String MSG_CAM_stopRecord = "stopRecord";

//        String MSG_CAM_manualMarkClip = "manualMarkClip";

        String MSG_CAM_VinMirror = "vinMirror";

        String MSG_CAM_MAC = "statusAlgorithm";

        String MSG_CAM_SRADAR = "statusSradar";

        String MSG_CAM_MODE_VISION = "modeVision";

        String MSG_CAM_Exboard = "statusExboard";

        String MSG_CAM_Licvlpr = "ivlprLicense";

        String MSG_CAM_HDRMode = "hdrMode";

        String MSG_CAM_MaxMarkSpace = "maxMarkSpace";

        String MSG_CAM_VirtualIgnition = "vtIgtCfg";

        String MSG_CAM_AdasCfg = "adasCfg";

        String MSG_CAM_AuxCfg = "auxCfg";

    }

    interface MK {
        String MSG_MK_TCVN01 = "01";
        String MSG_MK_TCVN02 = "02";
        String MSG_MK_TCVN03 = "03";
        String MSG_MK_TCVN04 = "04";
        String MSG_MK_TCVN05 = "05";

        String MSG_MK_INOUT = "in_out";

        String MSG_MK_DRIVER_INFO = "DriverInfoCfg";

        String MSG_MK_SETTING_CFG = "setting_cfg";
        String MSG_MK_SIM_DATA = "msgSimData";
        String MSG_MK_CARRIER = "msgCarrier";
        String MSG_MK_SEND_FACE = "msgFaceImage";
        String MSG_MK_SAVE_FACE_DATA = "msgFaceData";
        String MSG_MK_SEND_DATA_FW = "msgDataFW";

        String MSG_MK_MOC_METHOD = "msg_MOC_method";
    }

    //debug
//    interface DEB {
//
//    }
}
