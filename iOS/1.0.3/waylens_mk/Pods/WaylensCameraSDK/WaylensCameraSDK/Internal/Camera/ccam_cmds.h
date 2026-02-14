/*****************************************************************************
 * ccam_cmds.h:
 *****************************************************************************
 * Author: linnsong <linnsong@hotmail.com>
 *
 * Copyright (C) 1975 - , linnsong.
 *
 *
 *****************************************************************************/
#ifndef __H_ccam_cmds__
#define __H_ccam_cmds__
//#include "sd_general_description.h"

enum CMD_Domain
{
    CMD_Domain_cam = 0,
    CMD_Domain_p2p,
    CMD_Domain_rec,
    CMD_Domain_decode,
    CMD_Domain_network,
    CMD_Domain_power,
    CMD_Domain_storage,
    CMD_Domain_stream,
    CMD_Domain_MotorControl,
    CMD_Domain_num,
};
#define DomainCamera camera
#define DomainRec record
#define DomainDec decode
#define DomainNet network
#define DomainPower power
#define DomainStorage storage
#define DomainStream stream
#define DomainMotoControl MotorControl

enum CMD_Cam
{
    CMD_Cam_getMode             = 0,
    CMD_Cam_getMode_result      = 1,
    CMD_Cam_getAPIVersion       = 2,
    CMD_Cam_isAPISupported      = 3,
    CMD_Cam_get_Name            = 4,
    CMD_Cam_get_Name_result     = 5,
    CMD_Cam_set_Name            = 6,
    CMD_Cam_set_Name_result     = 7,
    CMD_Cam_get_State           = 8,
    CMD_Cam_get_State_result    = 9,
    CMD_Cam_start_rec           = 10,
    CMD_Cam_stop_rec            = 11,
    CMD_Cam_get_time            = 12,
    CMD_Cam_get_time_result     = 13,
    
    CMD_Cam_get_getAllInfor     = 14,
    CMD_Cam_get_getStorageInfor = 15,
    CMD_Cam_msg_Storage_infor   = 16,   // enum State_storage
    CMD_Cam_msg_StorageSpace_infor  = 17,   //all, free
    CMD_Cam_msg_Battery_infor   = 18,   // votage(int mv),  int percentage
    CMD_Cam_msg_power_infor     = 19,   //(char* charging.. full), (int online 0, 1)
    CMD_Cam_msg_BT_infor        = 20,   //
    CMD_Cam_msg_GPS_infor       = 21,
    CMD_Cam_msg_Internet_infor  = 22,
    CMD_Cam_msg_Mic_infor       = 23,   //enum State_Mic , gain (int)
    CMD_Cam_set_StreamSize      = 24,
    
    CMD_Cam_PowerOff            = 25,
    CMD_Cam_Reboot              = 26,
    
    CMD_Network_GetWLanMode     = 27,
    CMD_Network_GetHostNum      = 28,
    CMD_Network_GetHostInfor    = 29,
    CMD_Network_AddHost         = 30,
    CMD_Network_RmvHost         = 31,
    CMD_Network_ConnectHost     = 32,
    
    CMD_Network_Synctime        = 33,
    CMD_Network_GetDevicetime   = 34,
    
    CMD_Rec_error               = 35,
    
    CMD_audio_setMic            = 36,
    CMD_audio_getMicState       = 37,
    
    CMD_fw_getVersion           = 38,
    CMD_fw_newVersion           = 39,
    CMD_fw_doUpgrade            = 40,
    //1.1
    //1.2
    CMD_CAM_BT_isSupported      = 41,
    CMD_CAM_BT_isEnabled        = 42,
    CMD_CAM_BT_Enable           = 43,
    CMD_CAM_BT_getDEVStatus     = 44,
    CMD_CAM_BT_getHostNum       = 45,
    CMD_CAM_BT_getHostInfor     = 46,
    CMD_CAM_BT_doScan           = 47,
    CMD_CAM_BT_doBind           = 48,
    CMD_CAM_BT_doUnBind         = 49,
    CMD_CAM_BT_setOBDTypes      = 50,
    CMD_CAM_BT_RESERVED         = 51,
    /*
     CMD_CAM_Cloud_CheckBind     = 52,
     CMD_CAM_Cloud_TryBind       = 53,
     CMD_CAM_msg_Cloud_BindInfor = 54,
     CMD_CAM_Cloud_Upload_GetList = 55,
     CMD_CAM_Cloud_Upload_AddClip = 56,
     CMD_CAM_Cloud_Upload_DelClip = 57,
     CMD_CAM_Cloud_Upload_Start   = 58,
     CMD_CAM_Cloud_Upload_Pause   = 59,
     CMD_CAM_msg_Cloud_UploadInfo = 60,
     */
    //1.2
    
    //1.3
    CMD_CAM_Format_TF           = 61,
    CMD_CAM_Powersaving_Mode    = 62,
    CMD_CAM_Enter_Preview       = 63,
    CMD_CAM_Leave_Preview       = 64,
    CMD_CAM_Start_Playback      = 65,
    CMD_CAM_Stop_Playback       = 66,
    CMD_CAM_Get_Language_List   = 67,
    CMD_CAM_Get_Language        = 68,
    CMD_CAM_Set_Language        = 69,
    
    CMD_CAM_Set_WorkingMode     = 70,
    CMD_CAM_Get_WorkingMode     = 71,
    CMD_CAM_Set_PhotoLapse_Interval = 72,
    CMD_CAM_Get_PhotoLapse_Interval = 73,
    // end of API v1.3
    
    // 1.4
    CMD_Network_ScanHost            = 74,
    CMD_Network_ConnectHotSpot      = 75,
    CMD_Set_Auto_Power_Off_Delay    = 76,
    CMD_Get_Auto_Power_Off_Delay    = 77,
    CMD_Set_Speaker_Status          = 78,
    CMD_Get_Speaker_Status          = 79,
    CMD_Set_Display_Auto_Brightness = 80,
    CMD_Get_Display_Auto_Brightness = 81,
    CMD_Set_Display_Brightness      = 82,
    CMD_Get_Display_Brightness      = 83,
    CMD_Set_Display_Auto_Off_Time   = 84,
    CMD_Get_Display_Auto_Off_Time   = 85,
    CMD_Factory_Reset               = 86,
    
    CMD_Get_Connected_Clients_Info  = 87,
    CMD_CAM_NEW_CONNECTION          = 88,
    CMD_CAM_CLOSE_CONNECTION        = 89,
    // end of API v1.4

    // 1.5
    CMD_GET_OBD_VIN                 = 90,
    CMD_SET_CLIP_VIN_STYLE          = 91,
    CMD_GET_CLIP_VIN_STYLE          = 92,
    CMD_SET_Screen_Saver_Style      = 93,
    CMD_GET_Screen_Saver_Style      = 94,
    CMD_SET_Units_System            = 95,
    CMD_GET_Units_System            = 96,
    // end of API v1.5
    
    // oliver
    CMD_CAM_WantIdle = 100,
    CMD_CAM_WantPreview = 101,
    // some preservation for avf test cases
    
    // 1.6
    CMD_GET_LapTracks_Update_Port   = 150,
    CMD_GET_LapTracks_Info          = 151,
    CMD_SET_TeleNav_Token           = 152,
    CMD_GET_TeleNav_Token           = 153,
    // end of API v1.6
    // some preservation for telenav cases
    
    // 1.7
    CMD_Copy_Log                    = 170, // 0: failed; 1: ready to send;
    CMD_FW_Get_Key                  = 171,
    CMD_Get_360_Sever               = 172,
    CMD_Set_360_Sever               = 173,
    //
    CMD_Get_Mount_Settings          = 174,
    CMD_Set_Mount_Settings          = 175,
    //
    CMD_Get_Mount_Version           = 176,
    CMD_Get_Monitor_Mode            = 177,
    CMD_Get_HDR_Mode                = 178,
    CMD_Set_HDR_Mode                = 179,
    // end of API v 1.7
    //
    // 1.8, night vision time range for daytime

    CMD_360_START_INDEX             = 3600,
    // 1.9 apis for setting acc detection params
    CMD_Get_Mount_Accel_Levels      = CMD_360_START_INDEX + 0, // ["soft", "normal", "hard"], param2(current); default: "normal", may be "customized"
    CMD_Set_Mount_Accel_Level       = CMD_360_START_INDEX + 1, // default "normal". ["soft", "normal", "hard"] or "customized".
    //next 2 apis for internal use only
    CMD_Get_Mount_Accel_param       = CMD_360_START_INDEX + 2, // int level, return sdetection_accel_params
    CMD_Set_Mount_Accel_param       = CMD_360_START_INDEX + 3, // int level, sdetection_accel_params [0 1 2 3 4 5 6 7 8 9 10 11 12]

    CMD_Synctime_EX                 = CMD_360_START_INDEX + 4, // json: {time = %ld, timezone = %d, daylightsaving = bool} //timezone in sec
    CMD_GetTimeZone                 = CMD_360_START_INDEX + 5, // return json: {timezone = %d, daylightsaving = bool}
    
    CMD_GetMarkStorage              = CMD_360_START_INDEX + 6, // param1: currentGB, param2: list [16, 24, 32] // in GB
    CMD_SetMarkStorage              = CMD_360_START_INDEX + 7, // set a value, in GB. return param1.
    CMD_GetAudioPrompts             = CMD_360_START_INDEX + 8, // get a value, "on" or "off".
    CMD_SetAudioPrompts             = CMD_360_START_INDEX + 9, // set a value, "on" or "off".
    // end of API v 1.9
    
    // 1.10
    CMD_GetICCID                    = CMD_360_START_INDEX + 10, // get iccid, string.
    CMD_Get_LTE_FWVersion           = CMD_360_START_INDEX + 11, // get 4G modeul FW version, param1: public version; param2: internal version.
    CMD_Get_LTE_STATUS              = CMD_360_START_INDEX + 12, // get LTE status, include band, signal, ip, and so on. Json format.
    /*
    {
        sim = READY;
        apns = "1,[IP],[waylens.iot.com.attz],[0.0.0.0],0,0,0,0  2,[IPV4V6],[ims],[0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0],0,0,0,0  3,[IPV4V6],[sos],[0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0],0,0,0,1";
        band = "LTE: 5"; // GW: 8,9,10,23 CDMA:0 TDS:34,39 LTE: 1,3,38,39,40,41
        cellinfo = "0X5B23,0X0B149394,0X0000008A,LTE B5,2452";
        cereg = "0,1"; // n, stat  stat: [0 IDLE; 1 READY; 2 SEARCHING; 3 REFUESED; 4 UNKNOWN; 5 ROAMING]
        cgreg = "0,1";
        creg = "0,1";
        cops = "0,0,[CHN-CT],7";
        csq = "15,99"; // rssi, ber  rssi: [99: no network; 0: <=-113db; 1: -111db; 2~30: -109~-53db; 31: >= -51db]
        ip = "IPV4, 10.63.63.128, 10.63.63.129, 222.66.251.8, 116.236.159.8"; // type, ip, gw, dns, dns
        network = "[LTE],[PS_ONLY],[FDD]";
        signal = "138,2452,[-105.50]"; // pci, arfcn, [rsrp]
        ping8888 = yes;
        connected = yes;
    }
     */

    CMD_DEBUG_PROPS                 = CMD_360_START_INDEX + 13, // debug only.
    // param1: 0: get; 1: set.
    // param2: json. must contain 1.3.4, or 2.3.4
    //      key1 - "prop" : "xxx.xxx.xxx". val = prop value
    //      key2 - "action" : "xxx". setLteBand only: val: 0: unlock, 1: lock.
    //      key3 - "val" : "xxx".
    //      key4 - "magic" : "311886.waylens.com". must

    CMD_Get_Mount_MW_Sensitivity    = CMD_360_START_INDEX + 14, // [0-10], lager value means more sensitive;
    CMD_Set_Mount_MW_Sensitivity    = CMD_360_START_INDEX + 15, // [0-10], lager value means more sensitive;; Only enabled if vercode is not unknown.
    
    // 1.12
    CMD_Get_Mount_ACC_Trust         = CMD_360_START_INDEX + 16, // 0: no trust, 1: trust
    CMD_Set_Mount_ACC_Trust         = CMD_360_START_INDEX + 17, // 0: no trust, 1: trust

    // 1.13
    CMD_Get_P2P_Enable              = CMD_360_START_INDEX + 18, // 0: no, 1: enable
    CMD_Set_P2P_Enable              = CMD_360_START_INDEX + 19, // 0: no, 1: enable
    CMD_Get_P2P_PairedList          = CMD_360_START_INDEX + 20, // json array: [{ name = xxx; mac = xxx;}, ...]
    CMD_Remove_P2P_PairedDev        = CMD_360_START_INDEX + 21, // mac, return 0/-1
    
    CMD_Get_KeepAlive_forApp        = CMD_360_START_INDEX + 22, // 0: no, 1: yes(default).
    CMD_Set_KeepAlive_forApp        = CMD_360_START_INDEX + 23, // 0: no, 1: enable
    
    CMD_Get_Attitude                = CMD_360_START_INDEX + 24, // "normal"(default) or "upsidedown".
    CMD_Set_Attitude                = CMD_360_START_INDEX + 25, // "normal" or "upsidedown".
    CMD_Support_UpsideDown          = CMD_360_START_INDEX + 28, // 1: support, 0: no.
    // 1.13

    CMD_Get_IIOEventDetectionParam  = CMD_360_START_INDEX + 26, // //[accel_th brake_th turn_th accel_width brake_width turn_width] default: [-330 220 375 15 15 15], 1<width<20
    CMD_Set_IIOEventDetectionParam  = CMD_360_START_INDEX + 27,

    // 1.14
    CMD_Get_SupportRiskDriveEvent   = CMD_360_START_INDEX + 29, // 1: support, 0: unsupport. default: 0 for 2C and 1 for 2B.
    CMD_Set_SupportRiskDriveEvent   = CMD_360_START_INDEX + 30,
    CMD_Get_APN                     = CMD_360_START_INDEX + 31,
    CMD_Set_APN                     = CMD_360_START_INDEX + 32,
    CMD_Get_SupportWlanMode         = CMD_360_START_INDEX + 33,
    CMD_Get_ProtectionVoltage       = CMD_360_START_INDEX + 34, // Int(mv). 11.7v-12.2v, 23.4v-24.5v
    CMD_Set_ProtectionVoltage       = CMD_360_START_INDEX + 35, // Int(mv). 11.7v-12.2v, 23.4v-24.5v
    CMD_Get_ParkSleepDelay          = CMD_360_START_INDEX + 36, // Int(s). default 30. 30, 60, 120, 300, 600.
    CMD_Set_ParkSleepDelay          = CMD_360_START_INDEX + 37, // Int(s). default 30. 30, 60, 120, 300, 600.

    //// 1.14.2
    CMD_Get_BNOCalibState           = CMD_360_START_INDEX + 38, // param1: 0 / 1, 1 means calibed; param2: 0xXX: Current state, >=0x3F means done.
    // end of API v1.14

    CMD_Get_OBDCfg = CMD_360_START_INDEX + 40,
    CMD_Set_OBDCfg = CMD_360_START_INDEX + 41,
    CMD_Get_OBDTotalCfg = CMD_360_START_INDEX + 42,
    CMD_Set_OBDTotalCfg = CMD_360_START_INDEX + 43,

    // virtual ignition
    CMD_Get_VtIgtCfg = CMD_360_START_INDEX + 44,
    CMD_Set_VtIgtCfg = CMD_360_START_INDEX + 45,
    
    CMD_Cam_num,
};

static const char* ErrRecodeDescription[5] = {
    "",
    "No SDCard",
    "Full",
    "Error",
    "Slow Error",
};

//typedef enum State_Cam_Mode
//{
//    State_Cam_Mode_idle = 0,
//    State_Cam_Mode_Record,
//    State_Cam_Mode_Decode,
//    State_Cam_Mode_Duplex,
//    State_Cam_Mode_Num,
//} eCameraMode;

typedef enum Storage_Rec_State
{
    Storage_Rec_State_Normal = 0,
    Storage_Rec_State_WriteSlow,
    Storage_Rec_State_SlowError,
    Storage_Rec_State_DiskError,
    Storage_Rec_State_num
} eStorageRecState;

typedef enum State_power
{
    State_battery_nobattery = 0,
    State_battery_battery,
    State_storage_charging,
} ePowerState;

typedef enum State_bluetooth
{
    State_bluetooth_diconnect = 0,
    State_bluetooth_paring,
    State_bluetooth_connected,
} eBluetoothState;

typedef enum State_GPS
{
    State_GPS_on = 0,
    State_GPS_ready,
    State_GPS_off,
} eGpsState;

typedef enum State_internet
{
    State_internet_nointernet = 0,
    State_internet_connecting,
    State_internet_connected,
    State_internet_tracing,
    State_internet_tracingOff,
} eInternetState;

typedef enum State_Mic
{
    State_Mic_ON = 0,
    State_Mic_MUTE,
} eMicState;

enum CMD_Rec
{
    CMD_Rec_Start               = 0,
    CMD_Rec_Stop                = 1,
    CMD_Rec_List_Resolutions    = 2,
    CMD_Rec_Set_Resolution      = 3,
    CMD_Rec_get_Resolution      = 4,
    CMD_Rec_List_Qualities      = 5,
    CMD_Rec_Set_Quality         = 6,
    CMD_Rec_get_Quality         = 7,
    CMD_Rec_List_RecModes       = 8,
    CMD_Rec_Set_RecMode         = 9,
    CMD_Rec_get_RecMode         = 10,
    CMD_Rec_List_ColorModes     = 11,
    CMD_Rec_Set_ColorMode       = 12,
    CMD_Rec_get_ColorMode       = 13,
    CMD_Rec_List_SegLens        = 14,
    CMD_Rec_Set_SegLen          = 15,
    CMD_Rec_get_SegLen          = 16,
    CMD_Rec_get_State           = 17,
    EVT_Rec_state_change        = 18,
    CMD_Rec_getTime             = 19,
    CMD_Rec_getTime_result      = 20,
    
    CMD_Rec_setDualStream       = 21,
    CMD_Rec_getDualStreamState  = 22,
    
    CMD_Rec_setOverlay          = 23, // time gps
    CMD_Rec_getOverlayState     = 24,
    //1.1
    
    //1.3
    CMD_Rec_Get_Rotate_Mode     = 25,
    CMD_Rec_Set_Rotate_Mode     = 26,
    CMD_Rec_Mark_Live_Video     = 27,
    CMD_Rec_Set_Mark_Time       = 28,
    CMD_Rec_Get_Mark_Time       = 29,
    // end of API v1.3
    
    // 1.6
    CMD_Rec_Get_Video_Quality   = 30, //obsolete
    CMD_Rec_Set_Video_Quality   = 31, //obsolete
    // end of API v1.6

    // 1.7.03
    CMD_Rec_Set_LoopMode        = 32, //obsolete
    CMD_Rec_get_LoopMode        = 33, //obsolete
    // end of API 1.7.03

    // 1.14
    CMD_Rec_Get_SubStreamOnly  = 34, // default 0, no; 1, yes
    CMD_Rec_Set_SubStreamOnly  = 35,
    // end of API 1.14

    // Still capture
    CMD_Rec_SetStillMode = 100,      // p1=0: video mode; 1: still mode
    CMD_Rec_StartStillCapture = 101,// p1=0: burst mode; 1: one-shot; echo back to notify user
    CMD_Rec_StopStillCapture = 102, //
    
    MSG_Rec_StillPictureInfo = 103, // p1=(burst_ticks<<1)|bursting, p2=num_pictures
    MSG_Rec_StillCaptureDone = 104,

    CMD_Rec_num,
};

enum CMD_Stream
{
    CMD_Stream_Start = 0,
    CMD_Stream_Stop,
    CMD_Stream_get_Address,
    CMD_Stream_List_Formats,
    CMD_Stream_Set_Format,
    CMD_Stream_get_Format,
};

enum CMD_Storage
{
    CMD_Storage_GetNum = 0,
    CMD_Storage_GetSize,
    CMD_Storage_GetFreeSpace,
};

typedef enum CameraNetworkMode {
    CameraNetworkModeAccessPoint,
    CameraNetworkModeClient
} CameraNetworkMode;

/*
enum CMD_Network
{
 CMD_Network_GetIfNum = 0,
 CMD_Network_GetIfState,
 CMD_Network_GetIfIpaddress,
 CMD_Network_GetWLanAPState,
 CMD_Network_GetWLanCLTState,
 CMD_Network_GetWLanMode,
 CMD_Network_GetHostNameList,
 CMD_Network_AddHost,
 CMD_Network_RmvHost,
};*/

enum CMD_Movement
{
    CMD_Forward_angles = 0,
    CMD_Backward_angles,
    CMD_Forward_steps,
    CMD_Backward_steps,
    CMD_Go_ABSPosition,
};


typedef struct SessionDataHead
{
    int length;
    int appendLength;
    char data[120];
}SessionDataHead;

#endif
