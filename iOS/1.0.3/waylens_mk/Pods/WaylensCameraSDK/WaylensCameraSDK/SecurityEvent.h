//
//  SecurityEvent.h
//  Acht
//
//  Created by Chester Shen on 9/8/17.
//  Copyright © 2017 waylens. All rights reserved.
//

#ifndef SecurityEvent_h
#define SecurityEvent_h

typedef NS_ENUM(uint32_t, VIDEO_EVENT_TYPE) {
    VIDEO_EVENT_TYPE_NULL = 0,
    // trigger by MCU
    VIDEO_EVENT_TYPE_Motion,        // radar
    VIDEO_EVENT_TYPE_Park_light,    // high sensitive
    VIDEO_EVENT_TYPE_Park_heavy,    // low sensitive, serious event
    // trigger by gyro
    VIDEO_EVENT_TYPE_Drive_light,   // high sensitive, only for backwards compatible.
    VIDEO_EVENT_TYPE_Drive_heavy,   // low sensitive, serious event
    VIDEO_EVENT_TYPE_Hard_Accel,
    VIDEO_EVENT_TYPE_Hard_Brake,
    VIDEO_EVENT_TYPE_Sharp_Turn,
    VIDEO_EVENT_TYPE_Harsh_Accel,
    VIDEO_EVENT_TYPE_Harsh_Brake,
    VIDEO_EVENT_TYPE_Harsh_Turn,
    VIDEO_EVENT_TYPE_Severe_Accel,
    VIDEO_EVENT_TYPE_Severe_Brake,
    VIDEO_EVENT_TYPE_Severe_Turn,
};

typedef NS_ENUM(uint8_t, VIDEO_EVENT_LEVEL) {
    VIDEO_EVENT_LEVEL_DEFAULT = 0,
    VIDEO_EVENT_LEVEL_HARD = 1,
    VIDEO_EVENT_LEVEL_HARSH = 2,
    VIDEO_EVENT_LEVEL_SEVERE = 3,
};

typedef struct ParkSceneData {
    uint32_t fourcc;
    uint32_t data_size;
    VIDEO_EVENT_TYPE type;
} ParkSceneData;

typedef NS_ENUM(uint32_t, DMS_STATUS) {
    DMS_unknown     = 0,
    DMS_noDriver    = 1,
    DMS_normal      = 2,
    //
    DMS_drowsiness  = 5,
    DMS_phoneCall   = 6,
    DMS_drinking    = 7,
    DMS_smoking     = 8,
    //
    DMS_asleep      = 9,
    DMS_daydreaming = 10,
    DMS_yawn        = 11,
    DMS_distracted  = 12,
    DMS_attentive   = 13,
    //
    DMS_noSeatBelt  = 14,
};

typedef NS_ENUM(uint32_t, ADAS_STATUS) {
    ADAS_unknown = 0,
    ADAS_fcw  = 1, // Forward Collision Warning
    ADAS_hmw  = 2, // Headway Monitoring Warning
    ADAS_hme  = 3, // Headway Monitoring Emergency
    ADAS_ldw  = 4, // Lane Departure Warning
    ADAS_StatusNum = 5,
};

typedef struct EventSceneData {
    uint32_t fourcc;
    uint32_t data_size;
    union {
        VIDEO_EVENT_TYPE type;
        DMS_STATUS dms;
        ADAS_STATUS adas_type;
    };
    uint32_t reserved0;
    double date;
    VIDEO_EVENT_LEVEL level;
    uint8_t reserved[7];
} EventSceneData;

#endif /* SecurityEvent_h */
