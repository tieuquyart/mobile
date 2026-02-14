//
//  vdb_ios_types.h
//  Hachi
//
//  Created by gliu on 10/26/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#ifndef vdb_ios_types_h
#define vdb_ios_types_h

#include "vdb_cmd.h"
#include "avf_std_media.h"

typedef vdb_clip_info_t     clipInfor;
typedef vdb_clip_info_ex_t  clipInforEx;
typedef vdb_playlist_info_t playlistInfo;

//@interface VDBGPSInfor : NSObject
//
//@property (nonatomic) gpsInfor_t mInfo;
//- (id)initWithInfor:(gpsInfor_t*)info;
//@end

typedef struct accInfor {
    int x;
    int y;
    int z;
} accInfor_t;
typedef accInfor_t gyroInfor_t;

typedef struct iioInfor {
    double  time;
    iio_raw_data_t iio;
    //    gyroInfor_t gyro;
} iioInfor_t;

//@interface IIOGPSInfor : NSObject
//
//@property (nonatomic) iioInfor_t mInfo;
//- (id)initWithInfor:(iioInfor_t*)info;
//@end

typedef struct obdInfor {
    double  time;
    float   speed;
    float   rpm;
    float   throttle;
    float   psi; //in PSI
    float   barometricPressure;
} obdInfor_t;

//@interface OBDGPSInfor : NSObject
//
//@property (nonatomic) iioInfor_t mInfo;
//- (id)initWithInfor:(iioInfor_t*)info;
//@end

#endif /* vdb_ios_types_h */
