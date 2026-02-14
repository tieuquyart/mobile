//
//  WLDefine.h
//  Acht
//
//  Created by forkon on 2020/2/26.
//  Copyright © 2020 waylens. All rights reserved.
//

#ifndef Define_h
#define Define_h

typedef void (^WLDmsCameraCalibrateCompletionHandler)(BOOL);

typedef NS_ENUM(NSInteger, WLCommunicationProtocolVersion) {
    CommunicationProtocolVersionCamClient,
    CommunicationProtocolVersionEvcam,
    CommunicationProtocolVersionUnknown
};

typedef NS_ENUM(NSInteger, WLStorageState) {
    WLStorageStateNoStorage = 0,
    WLStorageStateLoading,
    WLStorageStateReady,
    WLStorageStateError,
    WLStorageStateUsbDisc,
    WLStorageStateNum
};

typedef NS_ENUM(NSInteger, WLRecordState) {
    WLRecordStateStopped = 0,
    WLRecordStateStopping,
    WLRecordStateStarting,
    WLRecordStateRecording,
    WLRecordStateClosed,
    WLRecordStateOpening,
    WLRecordStateError,
    WLRecordStateWriteSlow,
    WLRecordStateSwitching,  // switching still/video mode
    WLRecordStatePhotoLapse,
    WLRecordStatePhotoLapseShutdown,
    WLRecordStateNum,
};

typedef NS_ENUM(NSInteger, WLCameraHDRMode) {
    WLCameraHDRModeOn = 0,
    WLCameraHDRModeOff,
    WLCameraHDRModeAuto
};

typedef enum CameraRotateMode
{
    CameraRotateModeNormal = 0,
    CameraRotateMode180,
    CameraRotateModeAuto
} WLCameraRotateMode;

typedef enum {
    BTType_OBD,
    BTType_HID,
    BTType_NUM,
} eBTType;

typedef enum Video_Resolution
{
    Video_Resolution_1080p30 = 0,
    Video_Resolution_1080p60,
    Video_Resolution_720p30,
    Video_Resolution_720p60,
    Video_Resolution_4Kp30,
    Video_Resolution_4Kp60,
    Video_Resolution_480p30,
    Video_Resolution_480p60,
    Video_Resolution_720p120,   // TODO
    Video_Resolution_Still,     // TODO
    Video_Resolution_QXGAp30,   // 3M 2048x1536
    Video_Resolution_1080p23976,
    Video_Resolution_360_1952x1952p30,   // 4M 1952x1952p30
    Video_Resolution_num,
} eVideoResolution;

typedef enum Video_Quality
{
    Video_Quality_Supper = 0,
    Video_Quality_HI,
    Video_Quality_Mid,
    Video_Quality_LOW,
    Video_Quality_SuperLOW,
    Video_Quality_Mid_5FPS,
    Video_Quality_LOW_5FPS,
    Video_Quality_SuperLOW_5FPS,
    Video_Quality_num,
} WLVideoQuality;

typedef enum Rec_Mode
{
    Rec_Mode_Manual = 0,    //all manually
    Rec_Mode_AutoStart,     // start record when power on
    Rec_Mode_Manual_circle, //circle buffer
    Rec_Mode_AutoStart_circle, //auto start and circle buffer
    Rec_Mode_Mannual_Recording = Rec_Mode_Manual_circle,
    Rec_Mode_Continous_Recording = Rec_Mode_AutoStart_circle,
    Rec_Mode_num,
} WLRecordMode;

typedef enum Color_Mode
{
    Color_Mode_NORMAL = 0,
    Color_Mode_SPORT,
    Color_Mode_CARDV,
    Color_Mode_SCENE,
    Color_Mode_num,
} eColorMode;

typedef enum{
    BTStatus_OFF = 0,
    BTStatus_ON,
    BTStatus_Busy,
    BTStatus_Wait,
    BTStatus_Num,
} WLBluetoothStatus;

enum Wifi_Mode
{
    Wifi_Mode_AP        = 0,
    Wifi_Mode_Client    = 1,
    Wifi_Mode_Off       = 2,
    Wifi_Mode_MultiRole = 3,
};

typedef enum Wifi_Mode WLWiFiMode;

#define WiFiModeAP          Wifi_Mode_AP
#define WiFiModeClient      Wifi_Mode_Client
#define WiFiModeOff         Wifi_Mode_Off
#define WiFiModeMultiRole   Wifi_Mode_MultiRole

typedef enum Rec_Error_code
{
    Error_code_none = 0,
    Error_code_notfcard,
    Error_code_tfFull,
    Error_code_tfError,
} ErrRecode;

#define EYESIGHT_DATA_F_L1_HAS_PERSON_ID (1 << 1)

typedef struct eyesight_dms_data_header_s {
    uint32_t version;
    uint32_t revision;
    uint16_t src_width;        // input video size
    uint16_t src_height;
    uint16_t input_xoff;    // a rectangle in input video
    uint16_t input_yoff;
    uint16_t input_width;
    uint16_t input_height;
    uint16_t dms_width;        // after resizing
    uint16_t dms_height;
    uint32_t flags;
    uint32_t isDriverValid;    // for all levels
    uint32_t level;            // 0: no data; 1: L1; 2: L2
    uint32_t data_size;
} eyesight_dms_data_header_t;

typedef struct eyesight_person_info_s {
    uint32_t faceid_lo;
    uint32_t faceid_hi;
    uint8_t name[32];
    uint32_t person_id;
} eyesight_person_info_t;

typedef struct readsense_dms_data_items_s {
    int32_t ntrack_id;
    float rect_f_x;    // x,y,width,height
    float rect_f_y;
    float rect_f_width;
    float rect_f_height;
    float vec_points[68][2];
    float fyaw;
    float fpitch;
    float froll;
    float fyaw_gaze;
    float fpitch_gaze;
    float froll_gaze;
    float face_quality;
    float fth_emotion;
    int32_t nglass;
    uint8_t b_open_eye;
    uint8_t b_open_mouth;
    uint8_t b_smoke;
    uint8_t b_phone;
    uint8_t b_water;
    uint8_t _b_drawsy;      // filled by avf
    uint8_t _b_glass;       // filled by avf
    uint8_t _b_attention;   // filled by avf
    uint32_t flags;         // 0
    uint32_t reserved[4];
} readsense_dms_data_items_t;

typedef struct readsense_dms_data_header_s {
    uint32_t version;
    uint32_t reserved;
    uint32_t input_width;
    uint32_t input_height;
    uint32_t nitems;        // number of items
    uint32_t item_size;        // item size
} readsense_dms_data_header_t;

typedef struct readsense_dms_data_faceid_s {
    uint32_t faceid_valid;
    uint32_t reserved;
    uint64_t faceid;
    uint8_t name[32];
} readsense_dms_data_faceid_t;

typedef struct readsense_dms_data_s {
    readsense_dms_data_header_t header;
    readsense_dms_data_items_t items;
} readsense_dms_data_t;

typedef struct readsense_dms_data_v2_s {
//    readsense_dms_data_header_t header;
//    readsense_dms_data_item_v2_t items;
    readsense_dms_data_t v1;
    readsense_dms_data_faceid_t face;
} readsense_dms_data_v2_t;

// clip types
#define CLIP_TYPE_UNSPECIFIED    ((unsigned)-1)    // for vdb_clip_t, used by VDB_CMD_GetIndexPicture
#define CLIP_TYPE_BUFFER        0        // buffered clip list
#define CLIP_TYPE_MARKED        1        // marked clip list
// 2-0xFF: reserved for now
#define CLIP_TYPE_PLIST0    0x100    // the first playlist
#define NUM_PLISTS            5

// streams
enum {
    STREAM_MAIN = 0,
    STREAM_SUB_1 = 1,
    STREAM_SUB_2 = 2,
    STREAM_SUB_3 = 3,
    STREAM_SUB_4 = 4,
    MAX_VDB_STREAMS
};

// 32-byte ack header
// for each ACK and MSG
typedef struct vdb_ack_s {
    uint32_t magic;            // VDB_ACK_MAGIC
    uint32_t seqid;            // sequence id

    uint32_t user1;            // return user1 in vdb_cmd_header_t
    uint32_t user2;            // return user2 in vdb_cmd_header_t
    uint16_t cmd_code;        // return cmd_code in vdb_cmd_header_t
    uint16_t cmd_flags;        // return cmd_flags in vdb_cmd_header_t
    uint32_t cmd_tag;        // return cmd_tag in vdb_cmd_header_t

    int32_t ret_code;        // 0: success
    uint32_t extra_bytes;    // bytes after the 160-byte header
} vdb_ack_t;

//-----------------------------------------------------------------------
//
//  stream info (16 bytes)
//
//-----------------------------------------------------------------------
typedef struct avf_stream_attr_s {
    // flags
    uint8_t stream_version;        // 0: invalid stream; should set to CURRENT_STREAM_VERSION
    uint8_t video_version;
    uint8_t audio_version;
    uint8_t extra_size;
    // video
    uint8_t video_coding;        // VideoCoding_Unknown
    uint8_t video_framerate;        // FrameRate_Unknown
    uint16_t video_width;
    uint16_t video_height;
    // audio
    uint8_t audio_coding;        // AudioCoding_Unknown
    uint8_t audio_num_channels;
    uint32_t audio_sampling_freq;    // 48000
    // uint8_t extra_data[extra_size];
} avf_stream_attr_t;

typedef struct vdb_msg_ClipInfo_s {
    vdb_ack_t header;    // must be first
    ///
    uint16_t action;        // CLIP_ACTION_CREATED, etc
    uint16_t flags;        // CLIP_IS_LIVE
    uint32_t list_pos;    // for CLIP_ACTION_INSERTED, CLIP_ACTION_MOVED
    ///
    uint32_t clip_type;
    uint32_t clip_id;
    uint32_t clip_date;
    uint32_t clip_duration_ms;
    uint32_t clip_start_time_ms_lo;
    uint32_t clip_start_time_ms_hi;
    ///
    uint16_t num_streams;
    uint16_t reserved;
    avf_stream_attr_t stream_info[MAX_VDB_STREAMS];

    //    if (VDB_HAS_ID) {
    //        vdb_id_t vdb_id;
    //    }

} vdb_msg_ClipInfo_t;

typedef struct vdb_ack_GetClipExtent_s {
    uint32_t clip_type;
    uint32_t clip_id;

    uint32_t real_clip_id;            // don't use
    uint32_t buffered_clip_id;

    uint32_t min_clip_start_tims_ms_lo;    // min clip_start_time_ms
    uint32_t min_clip_start_time_ms_hi;

    uint32_t max_clip_end_time_ms_lo;    // max clip_end_time_ms
    uint32_t max_clip_end_time_ms_hi;

    uint32_t clip_start_time_ms_lo;        // curr clip_start_time_ms
    uint32_t clip_start_time_ms_hi;

    uint32_t clip_end_time_ms_lo;        // curr clip_end_time_ms
    uint32_t clip_end_time_ms_hi;

    //    if (VDB_HAS_ID) {
    //        vdb_id_t vdb_id;
    //    }

} vdb_ack_GetClipExtent_t;

typedef struct gpsInfor {
    double  time;         //unit s
    double  longitude;
    double  latitude;
    float   altitude;
    float   speed;
    float   orientation;
    int  hdop;
    int  vdop;
    uint64_t absoluteTime; //unit ms
} gpsInfor_t;

//-----------------------------------------------------------------------
//
//    acc/iio raw data structure
//
//-----------------------------------------------------------------------
typedef struct acc_raw_data_s {
    int32_t accel_x;
    int32_t accel_y;
    int32_t accel_z;
} acc_raw_data_t;

typedef struct iio_raw_data_s {

    // accel : g x 1000 = mg
    int32_t accel_x;
    int32_t accel_y;
    int32_t accel_z;

    //---------------------------------------------------
    uint16_t version;    // IIO_VERSION
    uint16_t size;        // sizeof(iio_raw_data_s)
    uint32_t flags;        // IIO_F_ACCEL etc
    //---------------------------------------------------

    // gyro : Dps x 1000 = mDps
    int32_t gyro_x;
    int32_t gyro_y;
    int32_t gyro_z;

    // magn : uT x 1000000
    int32_t magn_x;
    int32_t magn_y;
    int32_t magn_z;

    // Orientation
    // Euler : Degrees x 1000 = mDegrees
    int32_t euler_heading;
    int32_t euler_roll;
    int32_t euler_pitch;

    // Quaternion : Raw, no unit
//    int32_t quaternion_w;
//    int32_t quaternion_x;
//    int32_t quaternion_y;
//    int32_t quaternion_z;

    // gravity : g x 1000 = mg
    int16_t gravity_x;
    int16_t gravity_y;
    int16_t gravity_z;

    // Raw accel : g x 1000 = mg
    int16_t raw_x;
    int16_t raw_y;
    int16_t raw_z;

    uint32_t reserved;

    // Pressure: Pa x 1000
    int32_t pressure;

} iio_raw_data_t;

// size: 48 bytes
typedef struct gps_raw_data_v3_s {
    uint32_t flags;    // GPS_F_LATLON, GPS_F_ALTITUDE, GPS_F_SPEED
    float speed;
    double latitude;
    double longitude;
    double altitude;
    ///
    uint32_t utc_time;
    float track;
    uint16_t _hdop;    //hdop x 100
    uint16_t _vdop;    //vdop x 100
    uint32_t utc_time_usec;
} gps_raw_data_v3_t;

// (pid,data) (pid,data) ... (pid,data) 0
// pid_data is little endian
typedef struct obd_raw_data_v2_s {
    uint8_t revision;    // OBD_VERSION_2
//    for (;;) {
//        uint8_t pid;
//        if (pid == 0)
//            break;
//        uint8_t pid_data[g_pid_data_size_table[pid]];
//    }
//    uint8_t padding_zeros[align_to_4n_byte];
} obd_raw_data_v2_t;


#endif /* Define_h */
