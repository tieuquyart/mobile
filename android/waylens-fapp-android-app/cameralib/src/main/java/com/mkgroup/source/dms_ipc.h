
#ifndef __DMS_IPC_H__
#define __DMS_IPC_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// cmds
enum {
    DMS_CMD_NONE = 0,
    DMS_CMD_GetVersionInfo = 1,
    DMS_CMD_ListFaceIds = 2,
    DMS_CMD_RemoveFaceId = 3,

    RS_CMD_START = 100,
    RS_CMD_CaptureImage = RS_CMD_START + 0,
    RS_CMD_AddFaceId = RS_CMD_START + 1,

    ES_CMD_START = 200,
    ES_CMD_StartUserEnrollment = ES_CMD_START + 1,
    ES_CMD_EstimateCameraPose = ES_CMD_START + 2,

    //
    ES_MSG_START = 400,
    ES_MSG_UserEnrollment = ES_MSG_START + 0,
};

#define DMS_IPC_VERSION_MAJOR    1
#define DMS_IPC_VERSION_MINOR    0

// little endian format

#define DMS_CMD_SIZE        160
#define DMS_ACK_SIZE        160
#define DMS_ACK_MAGIC        0xFAFBFCFF

// 16 bytes cmd header

typedef struct dms_ipc_cmd_header_s {
    uint16_t cmd_code;        // command code
    uint16_t cmd_flags;        // command flags
    uint32_t cmd_tag;        // will be returned in ack
    uint32_t user1;            // will be returned in ack
    uint32_t user2;            // will be returned in ack
} dms_ipc_cmd_header_t;

// 32 bytes ack header

typedef struct dms_ipc_ack_header_s {
    uint32_t magic;            // DMS_ACK_MAGIC
    uint32_t seqid;            // sequence id

    uint32_t user1;            // return user1 in vdb_cmd_header_t
    uint32_t user2;            // return user2 in vdb_cmd_header_t
    uint16_t cmd_code;        // return cmd_code in vdb_cmd_header_t
    uint16_t cmd_flags;        // return cmd_flags in vdb_cmd_header_t
    uint32_t cmd_tag;        // return cmd_tag in vdb_cmd_header_t

    int32_t ret_code;        // 0: success
    uint32_t extra_bytes;    // bytes after the 160-byte header
} dms_ipc_ack_header_t;

//-----------------------------------------------------------------------
//
//    DMS_CMD_GetVersionInfo
//
//-----------------------------------------------------------------------

typedef struct dms_cmd_GetVersionInfo_s {
    dms_ipc_cmd_header_t header;    // must be fist
} dms_cmd_GetVersionInfo_t;

enum {
    VENDOR_NONE = 0,
    VENDOR_READSENSE = 1,
    VENDOR_EYESIGHT = 2,
};

typedef struct dms_ack_GetVersionInfo_s {
    uint16_t major;        // RS_IPC_VERSION_MAJOR
    uint16_t minor;        // RS_IPC_VERSION_MINOR
    uint32_t vendor;
} dms_ack_GetVersionInfo_t;

//-----------------------------------------------------------------------
//
//    DMS_CMD_ListFaceIds
//
//-----------------------------------------------------------------------

#define FACEID_NAME_LEN        32

typedef struct dms_cmd_ListFaceIds_s {
    dms_ipc_cmd_header_t header;    // must be first
    uint32_t    reserved;
} dms_cmd_ListFaceIds_t;

typedef struct dms_face_item_s {
    uint32_t    faceid_lo;
    uint32_t    faceid_hi;
    uint8_t        name[FACEID_NAME_LEN];
} dms_face_item_t;

typedef struct dms_ack_ListFaceIds_s {
    uint32_t    reserved;
    uint32_t    num_ids;
    //
    //    for (i = 0; i < num_ids; i++) {
    //        uint32_t    faceid_lo;
    //        uint32_t    faceid_hi;
    //        uint8_t        name[FACEID_NAME_LEN];
    //    }
    //
    //
} dms_ack_ListFaceIds_t;

//-----------------------------------------------------------------------
//
//    DMS_CMD_RemoveFaceId
//
//-----------------------------------------------------------------------

typedef struct dms_cmd_RemoveFaceId_s {
    dms_ipc_cmd_header_t header;    // must be first
    uint32_t    faceid_lo;
    uint32_t    faceid_hi;
    uint32_t    remove_all;        // if set to 1, will remove all!
} dms_cmd_RemoveFaceId_t;

typedef struct dms_ack_RemoveFaceId_s {
    uint32_t    faceid_lo;
    uint32_t    faceid_hi;
    uint32_t    remove_all;
} dms_ack_RemoveFaceId_t;

//-----------------------------------------------------------------------
//
//    RS_CMD_CaptureImage
//
//-----------------------------------------------------------------------

typedef struct rs_cmd_CaptureImage_s {
    dms_ipc_cmd_header_t    header;    // must be first
    uint32_t    need_image_data;
} rs_cmd_CaptureImage_t;

typedef struct rs_ack_CaptureImage_s {
    uint8_t    has_face;
    uint8_t    has_image;
    uint8_t faceid_valid;
    uint8_t reserved;

    //    if (!has_face)
    //        return;

    uint32_t faceid_lo;
    uint32_t faceid_hi;
    uint8_t name[32];

    //    if (has_image) {
    //        uint32_t    image_format;
    //        uint32_t    width;
    //        uint32_t    height;
    //        uint32_t    pitch;
    //        uint32_t    size;
    //        uint8_t        data[size];
    //    }

} rs_ack_CaptureImage_t;

//-----------------------------------------------------------------------
//
//    RS_CMD_AddFaceId
//
//-----------------------------------------------------------------------

typedef struct rs_cmd_AddFaceId_t {
    dms_ipc_cmd_header_t    header;    // must be first
    uint32_t    faceid_lo;
    uint32_t    faceid_hi;
    uint8_t        name[FACEID_NAME_LEN];
} rs_cmd_AddFaceId_t;


//-----------------------------------------------------------------------
//
//    ES_CMD_StartUserEnrollment
//
//-----------------------------------------------------------------------

typedef struct es_cmd_StartUserEnrollment_s {
    dms_ipc_cmd_header_t    header;    // must be first
    uint32_t    faceid_lo;
    uint32_t    faceid_hi;
    uint8_t     name[FACEID_NAME_LEN];
} es_cmd_StartUserEnrollment_t;

//-----------------------------------------------------------------------
//
//    ES_CMD_EstimateCameraPose
//
//-----------------------------------------------------------------------

// to use, define
//    #define EYESIGHT_DMS
//    #include "DriverSenseEngine.h"

typedef struct sPoint3dF
{
    float x;                                              //!< X axis (longitudinal) value in centimeters. \n\n The default value is: 0.F
    float y;                                              //!< Y axis (transverse) value in centimeters. \n\n The default value is: 0.F
    float z;                                              //!< Z axis (vertical) value in centimeters. \n\n The default value is: 0.F
} tPoint3dF;

typedef struct sEulerAngles
{
    float yaw;                                            //!< Euler angle yaw (turning right and left) in degrees. Negative value means turning left. \n\n The default value is: 0.F
    float pitch;                                          //!< Euler angle pitch (turning up and down) in degrees. Negative value means tilt down. \n\n The default value is: 0.F
    float roll;                                           //!< Euler angle roll (tilting to the sides) in degrees. Negative value means rotate counterclockwise. \n\n The default value is: 0.F
} tEulerAngles;

typedef struct es_cmd_EstimateCameraPose_s {
    dms_ipc_cmd_header_t    header;    // must be first
//#ifdef EYESIGHT_DMS
    tEulerAngles    objectRotationCcs;
    tPoint3dF objectLocationCcs;
    tPoint3dF objectLocationVcs;
//#endif
} es_cmd_EstimateCameraPose_t;

typedef struct es_ack_EstimateCameraPose_s {
//#ifdef EYESIGHT_DMS
    tEulerAngles cameraRotationVcs;
    tPoint3dF cameraLocationVcs;
//#endif
} es_ack_EstimateCameraPose_t;

//-----------------------------------------------------------------------
//
//    ES_MSG_UserEnrollment
//
//-----------------------------------------------------------------------

enum {
    ES_R_ENROLLED = 0,
    ES_R_DB_FULL = 1,
    ES_R_USER_NOT_VALID = 2,
    ES_R_ERROR = 3,
};

typedef struct es_msg_UserEnrollment_s {
    int result;        // ES_R_ENROLLED etc
    uint32_t    faceid_lo;
    uint32_t    faceid_hi;
    //uint8_t        name[FACEID_NAME_LEN];
} es_msg_UserEnrollment_t;

#endif


