package com.mkgroup.camera.command;

/**
 * Created by doanvt on 2016/3/22.
 */
public interface VdtCameraCmdConsts {

    int VDT_CAM_PORT = 10086;

    interface DOMAIN {
        int CMD_DOMAIN_USER = -1;
        int CMD_DOMAIN_CAM = 0;
        int CMD_DOMAIN_P2P = 1;
        int CMD_DOMAIN_REC = 2;
        int CMD_DOMAIN_DECODE = 3;
        int CMD_DOMAIN_NETWORK = 4;
        int CMD_DOMAIN_POWER = 5;
        int CMD_DOMAIN_STORAGE = 6;
        int CMD_DOMAIN_STREAM = 7;
        int CMD_DOMAIN_MOTOR_CONTROL = 8;
    }

    interface CAM {
        int CMD_DOMAIN_CAM_START = 0;
        int CMD_CAM_GET_MODE = 0;
        int CMD_CAM_GET_MODE_RESULT = 1;
        int CMD_CAM_GET_API_VERSION = 2;
        int CMD_CAM_IS_API_SUPPORTED = 3;
        int CMD_CAM_GET_NAME = 4;
        int CMD_CAM_GET_NAME_RESULT = 5;
        int CMD_CAM_SET_NAME = 6;
        int CMD_CAM_SET_NAME_RESULT = 7;
        int CMD_CAM_GET_STATE = 8;
        int CMD_CAM_GET_STATE_RESULT = 9;
        int CMD_CAM_START_REC = 10;
        int CMD_CAM_STOP_REC = 11;
        int CMD_CAM_GET_TIME = 12;
        int CMD_CAM_GET_TIME_RESULT = 13;

        int CMD_CAM_GET_GET_ALL_INFOR = 14;
        int CMD_CAM_GET_GET_STORAGE_INFOR = 15;
        int CMD_CAM_MSG_STORAGE_INFOR = 16;
        int CMD_CAM_MSG_STORAGE_SPACE_INFOR = 17;
        int CMD_CAM_MSG_BATTERY_INFOR = 18;
        int CMD_CAM_MSG_POWER_INFOR = 19;
        int CMD_CAM_MSG_BT_INFOR = 20;
        int CMD_CAM_MSG_GPS_INFOR = 21;
        int CMD_CAM_MSG_INTERNET_INFOR = 22;
        int CMD_CAM_MSG_MIC_INFOR = 23;
        int CMD_CAM_SET_STREAM_SIZE = 24;

        int CMD_CAM_POWER_OFF = 25;
        int CMD_CAM_REBOOT = 26;

        int CMD_NETWORK_GET_WLAN_MODE = 27;
        int CMD_NETWORK_GET_HOST_NUM = 28;
        int CMD_NETWORK_GET_HOST_INFOR = 29;
        int CMD_NETWORK_ADD_HOST = 30;
        int CMD_NETWORK_RMV_HOST = 31;
        int CMD_NETWORK_CONNECT_HOST = 32;

        int CMD_NETWORK_SYNCTIME = 33;
        int CMD_NETWORK_GET_DEVICETIME = 34;

        int CMD_REC_ERROR = 35;

        int CMD_AUDIO_SET_MIC = 36;
        int CMD_AUDIO_GET_MIC_STATE = 37;

        int CMD_FW_GET_VERSION = 38;
        int CMD_FW_NEW_VERSION = 39;
        int CMD_FW_DO_UPGRADE = 40;

        //  1.2
        int CMD_CAM_BT_IS_SUPPORTED = 41;
        int CMD_CAM_BT_IS_ENABLED = 42;
        int CMD_CAM_BT_ENABLE = 43;
        int CMD_CAM_BT_GET_DEV_STATUS = 44;
        int CMD_CAM_BT_GET_HOST_NUM = 45;
        int CMD_CAM_BT_GET_HOST_INFOR = 46;
        int CMD_CAM_BT_DO_SCAN = 47;
        int CMD_CAM_BT_DO_BIND = 48;
        int CMD_CAM_BT_DO_UNBIND = 49;
        int CMD_CAM_BT_SET_OBD_TYPES = 50;
        int CMD_CAM_BT_RESERVED = 51;
        // end of API v1.2

        //  1.3
        int CMD_CAM_FORMAT_TF = 61;
        int CMD_CAM_POWERSAVING_MODE = 62;
        int CMD_CAM_ENTER_PREVIEW = 63;
        int CMD_CAM_LEAVE_PREVIEW = 64;
        int CMD_CAM_START_PLAYBACK = 65;
        int CMD_CAM_STOP_PLAYBACK = 66;
        int CMD_CAM_GET_LANGUAGE_LIST = 67;
        int CMD_CAM_GET_LANGUAGE = 68;
        int CMD_CAM_SET_LANGUAGE = 69;

        int CMD_CAM_SET_WORKINGMODE = 70;
        int CMD_CAM_GET_WORKINGMODE = 71;
        int CMD_CAM_SET_PHOTOLAPSE_INTERVAL = 72;
        int CMD_CAM_Get_PHOTOLAPSE_INTERVAL = 73;
        // end of API v1.3

        // 1.4
        int CMD_NETWORK_SCANHOST = 74;
        int CMD_NETWORK_CONNECTHOTSPOT = 75;
        int CMD_SET_AUTO_POWER_OFF_DELAY = 76;
        int CMD_GET_AUTO_POWER_OFF_DELAY = 77;
        int CMD_SET_SPEAKER_STATUS = 78;
        int CMD_GET_SPEAKER_STATUS = 79;
        int CMD_SET_DISPLAY_AUTO_BRIGHTNESS = 80;
        int CMD_GET_DISPLAY_AUTO_BRIGHTNESS = 81;
        int CMD_SET_DISPLAY_BRIGHTNESS = 82;
        int CMD_GET_DISPLAY_BRIGHTNESS = 83;
        int CMD_SET_DISPLAY_AUTO_OFF_TIME = 84;
        int CMD_GET_DISPLAY_AUTO_OFF_TIME = 85;
        int CMD_FACTORY_RESET = 86;

        int CMD_GET_CONNECTED_CLIENTS_INFO = 87;
        int CMD_CAM_NEW_CONNECTION = 88;
        int CMD_CAM_CLOSE_CONNECTION = 89;


        //  1.5
        int CMD_GET_OBD_VIN = 90;
        int CMD_SET_CLIP_VIN_STYLE = 91;
        int CMD_GET_CLIP_VIN_STYLE = 92;
        int CMD_SET_SCREEN_SAVER_STYLE = 93;
        int CMD_GET_SCREEN_SAVER_STYLE = 94;
        int CMD_SET_UNITS_SYSTEM = 95;
        int CMD_GET_UNITS_SYSTEM = 96;
        int CMD_IMAGE_RECOGNITION_RESULT = 97;


        // oliver
        int CMD_CAM_WANT_IDLE = 100;
        int CMD_CAM_WANT_PREVIEW = 101;

        // API 1.6
        int CMD_GET_LAPTRACKS_UPDATE_PORT = 150;
        int CMD_GET_LAPTRACKS_INFO = 151;
        int CMD_SET_TELENAV_TOKEN = 152;
        int CMD_GET_TELENAV_TOKEN = 153;
        // end of API 1.6

        // 1.7
        int CMD_Copy_Log = 170;
        int CMD_Copy_DebugLog = 169;
        int CMD_FW_Get_Key = 171;
        int CMD_Get_360_Server = 172;
        int CMD_Set_360_Server = 173;
        //
        int CMD_GET_MOUNT_SETTINGS = 174;
        int CMD_SET_MOUNT_SETTINGS = 175;
        //
        int CMD_GET_MOUNT_VERSION = 176;
        int CMD_GET_MONITOR_MODE = 177;
        int CMD_GET_HDR_MODE = 178;
        int CMD_SET_HDR_MODE = 179;

        //chen
        int CMD_360_START_INDEX = 3600;

        int CMD_GET_MOUNT_ACCEL_LEVELS = CMD_360_START_INDEX + 0; // ["soft", "normal", "hard"], param2(current); default: "normal", may be "customized"
        int CMD_SET_MOUNT_ACCEL_LEVELS = CMD_360_START_INDEX + 1; // default "normal". ["soft", "normal", "hard"] or "customized".

        int CMD_GET_MOUNT_ACCEL_PARAM = CMD_360_START_INDEX + 2; // int level, return sdetection_accel_params
        int CMD_SET_MOUNT_ACCEL_PARAM = CMD_360_START_INDEX + 3; // int level, sdetection_accel_params [0 1 2 3 4 5 6 7 8 9 10 11 12]

        int CMD_SYNCTIME_EX = CMD_360_START_INDEX + 4; // json: {time = %ld, timezone = %d, daylightsaving = bool} //timezone in sec
        int CMD_GETTIMEZONE = CMD_360_START_INDEX + 5; // return json: {timezone = %d, daylightsaving = bool}

        int CMD_GETMARKSTORAGE = CMD_360_START_INDEX + 6; // param1: currentGB, param2: list [16, 24, 32] // in GB
        int CMD_SETMARKSTORAGE = CMD_360_START_INDEX + 7; // set a value, in GB. return param1.

        int CMD_GET_AUDIO_PROMPTS = CMD_360_START_INDEX + 8; // get a value, "on" or "off".
        int CMD_SET_AUDIO_PROMPTS = CMD_360_START_INDEX + 9; // set a value, "on" or "off".

        int CMD_GET_ICCID = CMD_360_START_INDEX + 10; // get iccid, string

        int CMD_GET_LTE_FWVERSION = CMD_360_START_INDEX + 11; // get 4G model FW version, param1: public version; param2: internal version
        int CMD_GET_LTE_STATUS = CMD_360_START_INDEX + 12; // get LTE status, include band, signal, ip, and so on. Json format
        int CMD_SET_LTE_BAND = CMD_360_START_INDEX + 13; // debug api, set lte band. param1: 0:unlock; 1:lock. param2: "secure360.debug"(magic number)

        int CMD_GET_MOUNT_MW_SENSITIVITY = CMD_360_START_INDEX + 14; // [0-10], lager value means more sensitive;
        int CMD_SET_MOUNT_MW_SENSITIVITY = CMD_360_START_INDEX + 15; // [0-10], lager value means more sensitive; only enabled if vercode is not unknown.

        // support acc 1.12.01
        int CMD_GET_MOUNT_ACC_TRUST = CMD_360_START_INDEX + 16;// 0: trust, 1: no trust
        int CMD_SET_MOUNT_ACC_TRUST = CMD_360_START_INDEX + 17;// 0: trust, 1: no trust

        // 1.13
        int CMD_GET_P2P_ENABLE = CMD_360_START_INDEX + 18; // 0: no, 1: enable
        int CMD_SET_P2P_ENABLE = CMD_360_START_INDEX + 19; // 0: no, 1: enable

        int CMD_GET_P2P_PAIREDLIST = CMD_360_START_INDEX + 20; // json array: [{ name = xxx; mac = xxx;}, ...]
        int CMD_SET_REMOVE_P2P_PAIREDDEV = CMD_360_START_INDEX + 21; // mac, return 0/-1

        int CMD_GET_ATTITUDE = CMD_360_START_INDEX + 24; // "normal"(default) or "upsidedown".
        int CMD_SET_ATTITUDE = CMD_360_START_INDEX + 25; // "normal" or "upsidedown".
        int CMD_SUPPORT_UPSIDEDOWN = CMD_360_START_INDEX + 28; // 1: support, 0: no.

        int CMD_GET_EVENT_DETECTION_PARAM = CMD_360_START_INDEX + 26; // [accel_th brake_th turn_th accel_width brake_width turn_width] default: [-330 220 375 15 15 15], 1<width<20
        int CMD_SET_EVENT_DETECTION_PARAM = CMD_360_START_INDEX + 27;

        int CMD_GET_SUPPORT_RISK_DRIVE_EVENT = CMD_360_START_INDEX + 29; // 1: support, 0: unsupport. default: 0 for 2C and 1 for 2B.
        int CMD_SET_SUPPORT_RISK_DRIVE_EVENT = CMD_360_START_INDEX + 30;

        int CMD_GET_APN = CMD_360_START_INDEX + 31;
        int CMD_SET_APN = CMD_360_START_INDEX + 32;

        int CMD_SUPPORT_WLAN_MODE = CMD_360_START_INDEX + 33; // 0: unsupported; 1: support.

        int CMD_GET_PROTECTION_VOLTAGE = CMD_360_START_INDEX + 34; // Int(mv). 11.7v-12.2v, 23.4v-24.5v
        int CMD_SET_PROTECTION_VOLTAGE = CMD_360_START_INDEX + 35; // Int(mv). 11.7v-12.2v, 23.4v-24.5v

        int CMD_GET_PARK_SLEEP_DELAY = CMD_360_START_INDEX + 36; // Int(s). default 30. 30, 60, 120, 300, 600.
        int CMD_SET_PARK_SLEEP_DELAY = CMD_360_START_INDEX + 37; // Int(s). default 30. 30, 60, 120, 300, 600.

        int CMD_GET_VIRTUAL_IGNITION = CMD_360_START_INDEX + 44;
        int CMD_SET_VIRTUAL_IGNITION = CMD_360_START_INDEX + 45;
    }

    interface REC {
        int CMD_DOMAIN_REC_START = 0;
        int CMD_REC_START = 0;
        int CMD_REC_STOP = 1;
        int CMD_REC_LIST_RESOLUTIONS = 2;
        int CMD_REC_SET_RESOLUTION = 3;
        int CMD_REC_GET_RESOLUTION = 4;
        int CMD_REC_LIST_QUALITIES = 5;

        //设置两路的quality：第一个参数是main stream，第二个参数是sub stream；
        int CMD_REC_SET_QUALITY = 6;
        int CMD_REC_GET_QUALITY = 7;

        int CMD_REC_LIST_REC_MODES = 8;
        int CMD_REC_SET_REC_MODE = 9;
        int CMD_REC_GET_REC_MODE = 10;
        int CMD_REC_LIST_COLOR_MODES = 11;
        int CMD_REC_SET_COLOR_MODE = 12;
        int CMD_REC_GET_COLOR_MODE = 13;
        int CMD_REC_LIST_SEG_LENS = 14;
        int CMD_REC_SET_SEG_LEN = 15;
        int CMD_REC_GET_SEG_LEN = 16;
        int CMD_REC_GET_STATE = 17;
        int EVT_REC_STATE_CHANGE = 18;
        int CMD_REC_GET_TIME = 19;
        int CMD_REC_GET_TIME_RESULT = 20;

        int CMD_REC_SET_DUAL_STREAM = 21;
        int CMD_REC_GET_DUAL_STREAM_STATE = 22;

        int CMD_REC_SET_OVERLAY = 23;
        int CMD_REC_GET_OVERLAY_STATE = 24;

        //  1.3
        int CMD_REC_GET_ROTATE_MODE = 25;
        int CMD_REC_SET_ROTATE_MODE = 26;
        int CMD_REC_MARK_LIVE_VIDEO = 27;
        int CMD_REC_SET_MARK_TIME = 28;
        int CMD_REC_GET_MARK_TIME = 29;

        //  1.6
        int CMD_REC_GET_VIDEO_QUALITY = 30;
        int CMD_REC_SET_VIDEO_QUALITY = 31;

        //  1.7.03
        int CMD_REC_SET_LOOPMODE = 32;
        int CMD_REC_GET_LOOPMODE = 33;

        // 1.14
        // 设置/获取单路还是两路录制：
        int CMD_REC_GET_SUB_STREAM_ONLY = 34; // default 0, no; 1 means only one stream
        int CMD_REC_SET_SUB_STREAM_ONLY = 35;
    }

    // oliver
    int CMD_REC_SET_STILL_MODE = 100;
    int CMD_REC_START_STILL_CAPTURE = 101;
    int CMD_REC_STOP_STILL_CAPTURE = 102;

    int MSG_REC_STILL_PICTURE_INFO = 103;
    int MSG_REC_STILL_CAPTURE_DONE = 104;

    int USER_CMD_GET_SETUP = 1;
    int USER_CMD_EXIT_THREAD = 2;

    int COPY_LOG_PORT = 10098;
    int COPY_DEBUGLOG_PORT = 10099;
}
