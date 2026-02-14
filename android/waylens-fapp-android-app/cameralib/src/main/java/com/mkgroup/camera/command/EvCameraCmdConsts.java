package com.mkgroup.camera.command;

public interface EvCameraCmdConsts {

    int EV_CAM_PORT = 10088;
    int EV_CAM_PORT2 = 10099;

    //categories
    interface CAT {
        String CMD_CAT_DEVICE = "device";
        String CMD_CAT_CAMERA = "camera";
        String CMD_CAT_DEBUG = "debug";
    }

    //device
    interface DEV {
        String CMD_DEV_getDeviceInfo = "getDeviceInfo";

        String CMD_DEV_powerOff = "powerOff";

        String CMD_DEV_reboot = "reboot";

        String CMD_DEV_factoryReset = "factoryReset";

        String CMD_DEV_getTime = "getTime";
        String CMD_DEV_setTime = "setTime";

//        String CMD_DEV_syncTime = "syncTime";

        String CMD_DEV_getName = "getName";
        String CMD_DEV_setName = "setName";

//        String CMD_DEV_getDateTimeFormat = "getDateTimeFormat";
//        String CMD_DEV_setDateTimeFormat = "setDateTimeFormat";

        String CMD_DEV_getTFState = "getTFState";

//        String CMD_DEV_unmountTF = "unmountTF";

        String CMD_DEV_formatTF = "formatTF";

        String CMD_DEV_getMicState = "getMicState";
        String CMD_DEV_setMicState = "setMicState";

        String CMD_DEV_getSpeakerState = "getSpeakerState";
        String CMD_DEV_setSpeakerState = "setSpeakerState";

//        String CMD_DEV_getGPSState = "getGPSState";

//        String CMD_DEV_getWifiInfo = "getWifiInfo";
//        String CMD_DEV_setWifiMode = "setWifiMode";

        String CMD_DEV_transferFirmware = "transferFirmware";

//        String CMD_DEV_getLCDBrightness = "getLCDBrightness";
//        String CMD_DEV_setLCDBrightness = "setLCDBrightness";

//        String CMD_DEV_getScreenSaverTimeout = "getScreenSaverTimeout";
//        String CMD_DEV_setScreenSaverTimeout = "setScreenSaverTimeout";

//        String CMD_DEV_getGsensorSensitivity = "getGsensorSensitivity";
//        String CMD_DEV_setGsensorSensitivity = "setGsensorSensitivity";

//        String CMD_DEV_transferFile = "transferFile";

//        String CMD_DEV_getUserFileList = "getUserFileList";

//        String CMD_DEV_playFile = "playFile";

//        String CMD_DEV_displayFile = "displayFile";

        String CMD_DEV_getAccelDetectLevel = "getAccelDetectLevel";
        String CMD_DEV_setAccelDetectLevel = "setAccelDetectLevel";

        String CMD_DEV_getMWSensitivity = "getMWSensitivity";
        String CMD_DEV_setMWSensitivity = "setMWSensitivity";

        String CMD_DEV_getDriveBehaviourDetect = "getDriveBehaviourDetect";
        String CMD_DEV_setDriveBehaviourDetectEnabled = "setDriveBehaviourDetectEnabled";
        String CMD_DEV_setDriveBehaviourDetectParams = "setDriveBehaviourDetectParams";

        String CMD_DEV_getP2PInfo = "getP2PInfo";
        String CMD_DEV_setP2PEnable = "setP2PEnable";
        String CMD_DEV_removeP2PDevice = "removeP2PDevice";

        String CMD_DEV_getSupportWlanMode = "getSupportWlanMode";

        String CMD_DEV_getTrustACCStatus = "getTrustACCStatus";
        String CMD_DEV_setTrustACCStatus = "setTrustACCStatus";

        String CMD_DEV_getAudioPrompts = "getAudioPrompts";
        String CMD_DEV_setAudioPrompts = "setAudioPrompts";

        String CMD_DEV_getKeepAliveForApp = "getKeepAliveForApp";
        String CMD_DEV_setKeepAliveForApp = "setKeepAliveForApp";
        String CMD_DEV_keepAliveForApp = "keepAliveForApp";

        String CMD_DEV_getAttitude = "getAttitude";
        String CMD_DEV_setAttitude = "setAttitude";

        String CMD_DEV_getProtectionVoltage = "getProtectionVoltage";
        String CMD_DEV_setProtectionVoltage = "setProtectionVoltage";

        String CMD_DEV_getParkSleepDelay = "getParkSleepDelay";
        String CMD_DEV_setParkSleepDelay = "setParkSleepDelay";

        String CMD_DEV_getLTEInformation = "getLTEInformation";

        String CMD_DEV_getLTEStatus = "getLTEStatus";

        String CMD_DEV_setAPN = "setAPN";

        String CMD_DEV_getCameraLog = "getCameraLog";


        String CMD_DEV_getDebugReportLog = "getDebugReportLog";

        String CMD_DEV_getWiFiKey = "getWiFiKey";

        String CMD_DEV_getServerUrl = "getServerUrl";
        String CMD_DEV_setServerUrl = "setServerUrl";

        String CMD_DEV_getMountVersion = "getMountVersion";

        String CMD_DEV_getMountSettings = "getMountSettings";
        String CMD_DEV_setMountSettings = "setMountSettings";

        String CMD_DEV_getIgnitionMode = "getIgnitionMode";

        String CMD_DEV_getPowerState = "getPowerState";

        String CMD_DEV_getHotspotInfo = "getHotspotInfo";
        String CMD_DEV_setHotspotInfo = "setHotspotInfo";
    }

    //camera
    interface CAM {
        String CMD_CAM_getRecordConfigList = "getRecordConfigList";

        String CMD_CAM_getRecordConfig = "getRecordConfig";
        String CMD_CAM_setRecordConfig = "setRecordConfig";

//        String CMD_CAM_getRecordMode = "getRecordMode";
//        String CMD_CAM_setRecordMode = "setRecordMode";

//        String CMD_CAM_getVideoOverlay = "getVideoOverlay";
//        String CMD_CAM_setVideoOverlay = "setVideoOverlay";

        String CMD_CAM_getState = "getState";

//        String CMD_CAM_getMarkState = "getMarkState";

//        String CMD_CAM_getStorageSpaceInfo = "getStorageSpaceInfo";

        String CMD_CAM_getMarkSettings = "getMarkSettings";

        String CMD_CAM_setGsensorMarkSettings = "setGsensorMarkSettings";

        String CMD_CAM_setManualMarkSettings = "setManualMarkSettings";

        String CMD_CAM_startRecord = "startRecord";
        String CMD_CAM_stopRecord = "stopRecord";

        String CMD_CAM_manualMarkClip = "manualMarkClip";

        String CMD_CAM_setVinMirror = "setVinMirror";
        String CMD_CAM_getVinMirror = "getVinMirror";

        String CMD_CAM_getMacWlan0 =  "getStatusAlgorithm";
        String CMD_CAM_setMacWlan0 =  "setStatusAlgorithm";
        String CMD_CAM_setStatusIvlpr =  "setStatusIvlpr";

        String CMD_CAM_getModeVision =  "getModeVision";
        String CMD_CAM_setModeVision =  "setModeVision";

        String CMD_CAM_getStatusSradar =  "getStatusSradar";
        String CMD_CAM_setStatusExboard =  "setStatusExboard";
        String CMD_CAM_getStatusExboard =  "getStatusExboard";
        String CMD_CAM_setStatusCover =  "setStatusCover";


        String CMD_CAM_getHDRMode = "getHDRMode";
        String CMD_CAM_setHDRMode = "setHDRMode";

        String CMD_CAM_getMaxMarkSpace = "getMaxMarkSpace";
        String CMD_CAM_setMaxMarkSpace = "setMaxMarkSpace";

        String CMD_CAM_getVirtualIgnition = "getVtIgtCfg";
        String CMD_CAM_setVirtualIgnition = "setVtIgtCfg";

        String CMD_CAM_getAdasCfg = "getAdasCfg";
        String CMD_CAM_setAdasCfg = "setAdasCfg";

        String CMD_CAM_getAuxCfg = "getAuxCfg";
        String CMD_CAM_setAuxCfg = "setAuxCfg";
    }

    interface MK {
        String CMD_MK_TCVN01 = "TCVN_01";
        String CMD_MK_TCVN02 = "TCVN_02";
        String CMD_MK_TCVN03 = "TCVN_03";
        String CMD_MK_TCVN04 = "TCVN_04";
        String CMD_MK_TCVN05 = "TCVN_05";

        String CMD_MK_INOUT = "in_out";

        String CMD_MK_SET_DRIVER_INFO = "setDriverInfo";

        String CMD_MK_SETTING_CFG = "setting_cfg";

        String CMD_MK_CHECK_SIM_DATA = "checkSimData";

        String CMD_MK_CHECK_CARRIER = "checkCarrier";

        String CMD_MK_SEND_FACE_IMG = "sendFaceImage";

        String CMD_MK_SAVE_FACE_DATA = "saveFaceData";

        String CMD_MK_REMOVE_FACE_DATA = "removeFaceData";

        String CMD_MK_SEND_DATA_FW = "sendDataFW";

        String CMD_MK_MOC_CONFIG = "MOC_method";

        String CMD_MK_MOC_INFO = "get_MOC_method";
    }

    //debug
//    interface DEB {
//
//    }
}
