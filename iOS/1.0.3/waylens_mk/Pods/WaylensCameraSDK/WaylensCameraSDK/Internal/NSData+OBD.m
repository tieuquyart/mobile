//
//  NSData+AES.m
//  Hachi
//
//  Created by gliu on 15/3/23.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import "NSData+OBD.h"
#import <CommonCrypto/CommonCryptor.h>

#import "WLDefine.h"
#include "avf_std_media.h"

@implementation NSData (OBD)

- (uint32_t)revision {
    const void* buffer = [self bytes];
    obd_raw_data_t* obdData = (obd_raw_data_t*)buffer;
    if (obdData->revision == OBD_VERSION_1) {
        return OBD_VERSION_1;
    }
    obd_raw_data_v2_t *obdDatav2 = (obd_raw_data_v2_t*)buffer;
    return obdDatav2->revision;
}
- (uint16_t)getOBDV2DataOffsetWithPID:(uint8_t)pid {
    const char* buffer = [self bytes];
    uint16_t offset = sizeof(obd_raw_data_v2_t);
    while (offset < [self length]) {
        if (buffer[offset] == pid) {
            offset ++;
            break;
        } else if (buffer[offset] < sizeof(g_pid_data_size_table)/sizeof(g_pid_data_size_table[0])) {
            offset += g_pid_data_size_table[buffer[offset]] + 1;
        } else {
            offset = 0;
            break;
        }
    }
    if (offset >= [self length]) {
        offset = 0;
    }
    return offset;
}

- (NSString*)getOBDVIN_v1 {
    const void* buffer = [self bytes];
    obd_raw_data_t* obdData = (obd_raw_data_t*)buffer;
    long long offset = obdData->pid_polling_diff & 0x00ffff;
    if (offset + 17 <= [self length]) {
        NSString* vin = [NSString stringWithCString:((const char*)buffer+offset) encoding:NSUTF8StringEncoding];
        return vin;
    }
    NSLog(@"getOBDVIN_v1 Failed!!");
    return nil;
}
- (NSString*)getOBDVIN_v2 {
    //todo
    NSLog(@"getOBDVIN_v2 TODO!!");
    return nil;
}
- (float)getOBDSpeed_v1 {
    const void* buffer = [self bytes];
    obd_raw_data_t* obdData = (obd_raw_data_t*)buffer;
    obd_index_t* indexArray = (obd_index_t *)((const char*)buffer + sizeof(obd_raw_data_t));
    int indexNum = obdData->pid_info_size / sizeof(obd_index_t);
    unsigned char *data = (unsigned char *)((const char*)buffer + sizeof(obd_raw_data_t) + obdData->pid_info_size);
    if((indexNum > 0x0d) && (indexArray[0x0d].flag & 0x1)) {
        return data[indexArray[0x0d].offset]/1.61;
    }
    return 0;
}
- (float)getOBDSpeed_v2 {
    uint16_t offset = [self getOBDV2DataOffsetWithPID:0x0d];
    if (offset > 0) {
        const unsigned char* buffer = [self bytes];
        return buffer[offset] / 1.61;
    }
    return 0;
}

- (float)getOBDRPM_v1 {
    const void* buffer = [self bytes];
    obd_raw_data_t* obdData = (obd_raw_data_t*)buffer;
    obd_index_t* indexArray = (obd_index_t *)((const char*)buffer + sizeof(obd_raw_data_t));
    int indexNum = obdData->pid_info_size / sizeof(obd_index_t);
    unsigned char *data = (unsigned char *)((const char*)buffer + sizeof(obd_raw_data_t) + obdData->pid_info_size);
    if((indexNum > 0x0d) && (indexArray[0x0c].flag & 0x1)) {
        int _OBD_rpm = 0;
        _OBD_rpm = data[indexArray[0x0c].offset];
        _OBD_rpm <<= 8;
        _OBD_rpm |= data[indexArray[0x0c].offset+1];
        _OBD_rpm >>= 2;
        return _OBD_rpm;
    }
    return 0;
}
- (float)getOBDRPM_v2 {
    uint16_t offset = [self getOBDV2DataOffsetWithPID:0x0c];
    if (offset > 0) {
        const unsigned char* buffer = [self bytes];
        int _OBD_rpm = 0;
        _OBD_rpm = buffer[offset];
        _OBD_rpm <<= 8;
        _OBD_rpm |= buffer[offset + 1];
        _OBD_rpm >>= 2;
        return _OBD_rpm;
    }
    return 0;
}
- (float)getOBDThrottle_v1 {
    const void* buffer = [self bytes];
    obd_raw_data_t* obdData = (obd_raw_data_t*)buffer;
    obd_index_t* indexArray = (obd_index_t *)((const char*)buffer + sizeof(obd_raw_data_t));
    int indexNum = obdData->pid_info_size / sizeof(obd_index_t);
    unsigned char *data = (unsigned char *)((const char*)buffer + sizeof(obd_raw_data_t) + obdData->pid_info_size);
    if((indexNum > 0x11) && indexArray[0x11].flag & 0x1) {
        return data[indexArray[0x11].offset]/2.55;
    }
    return 0;
}
- (float)getOBDThrottle_v2 {
    const unsigned char* buffer = [self bytes];
    uint16_t offset = [self getOBDV2DataOffsetWithPID:0x11];
    if (offset > 0) {
        return buffer[offset]/2.55;
    }
    return 0;
}
- (float)getOBDPsi_v1 {
    const void* buffer = [self bytes];
    obd_raw_data_t* obdData = (obd_raw_data_t*)buffer;
    obd_index_t* indexArray = (obd_index_t *)((const char*)buffer + sizeof(obd_raw_data_t));
    int indexNum = obdData->pid_info_size / sizeof(obd_index_t);
    unsigned char *data = (unsigned char *)((const char*)buffer + sizeof(obd_raw_data_t) + obdData->pid_info_size);
    if ((indexNum > 0x33) &&  indexArray[0x33].flag & 0x1 && indexArray[0x0b].flag & 0x1) {
        return (data[indexArray[0x0b].offset] - data[indexArray[0x33].offset])/6.895;
    }
    return 0;
}
- (float)getOBDPsi_v2WithPressure:(int)kPa {
    const unsigned char* buffer = [self bytes];
    uint16_t offset = 0;
    int pid4f = 0;
    float presurekpa = [self getOBDBarometricPressure_v2WithPressure:kPa];
    float pid0b = 0;
    offset = [self getOBDV2DataOffsetWithPID:0x0b];
    if ((offset > 0)) {
        pid0b = buffer[offset];
        offset = [self getOBDV2DataOffsetWithPID:0x4f];
        if (offset > 0) {
            pid4f = buffer[offset];
            if (pid4f > 0) {
                pid0b = pid0b * pid4f * 10 / 255;
            }
        }
        return (pid0b - presurekpa * 3.386) / 6.895;
    }
    return 0;
}
- (float)getOBDBarometricPressure_v1 {
    const void* buffer = [self bytes];
    obd_raw_data_t* obdData = (obd_raw_data_t*)buffer;
    obd_index_t* indexArray = (obd_index_t *)((const char*)buffer + sizeof(obd_raw_data_t));
    int indexNum = obdData->pid_info_size / sizeof(obd_index_t);
    unsigned char *data = (unsigned char *)((const char*)buffer + sizeof(obd_raw_data_t) + obdData->pid_info_size);

    if ((indexNum > 0x33) &&  indexArray[0x33].flag) {
        return data[indexArray[0x33].offset]/3.386;
    }
    return 0;
}
- (float)getOBDBarometricPressure_v2WithPressure:(int)kPa {
    const unsigned char* buffer = [self bytes];
    uint16_t offset = [self getOBDV2DataOffsetWithPID:0x33];
    if ((offset > 0)) {
        return buffer[offset] /3.386;
    }
    return kPa/3.386;
}

#pragma OBD API
- (NSString*)getOBDVIN {
    NSString* sVin = nil;
    switch ([self revision]) {
        case OBD_VERSION_1:
            sVin = [self getOBDVIN_v1];
            break;
        case OBD_VERSION_2:
            sVin = [self getOBDVIN_v2];
            break;
        default:
            NSLog(@"getOBDVIN Failed!!");
            break;
    }
    return sVin;
}

- (float)getOBDSpeed {
    float speed = 0;
    switch ([self revision]) {
        case OBD_VERSION_1:
            speed = [self getOBDSpeed_v1];
            break;
        case OBD_VERSION_2:
            speed = [self getOBDSpeed_v2];
            break;
        default:
            NSLog(@"getOBDSpeed Failed!!");
            break;
    }
    return speed;
}
- (float)getOBDRPM {
    float rpm = 0;
    switch ([self revision]) {
        case OBD_VERSION_1:
            rpm = [self getOBDRPM_v1];
            break;
        case OBD_VERSION_2:
            rpm = [self getOBDRPM_v2];
            break;
        default:
            NSLog(@"getOBDRPM Failed!!");
            break;
    }
    return rpm;
}
- (float)getOBDThrottle {
    float throttle = 0;
    switch ([self revision]) {
        case OBD_VERSION_1:
            throttle = [self getOBDThrottle_v1];
            break;
        case OBD_VERSION_2:
            throttle = [self getOBDThrottle_v2];
            break;
        default:
            NSLog(@"getOBDThrottle Failed!!");
            break;
    }
    return throttle;
}
- (float)getOBDPsiWithPressure:(int)kPa {
    float psi = 0;
    switch ([self revision]) {
        case OBD_VERSION_1:
            psi = [self getOBDPsi_v1];
            break;
        case OBD_VERSION_2:
            psi = [self getOBDPsi_v2WithPressure:kPa];
            break;
        default:
            NSLog(@"getOBDPsi Failed!!");
            break;
    }
    return psi;
}
- (float)getOBDBarometricPressureWithPressure:(int)kPa {
    float bp = 0;
    switch ([self revision]) {
        case OBD_VERSION_1:
            bp = [self getOBDBarometricPressure_v1];
            break;
        case OBD_VERSION_2:
            bp = [self getOBDBarometricPressure_v2WithPressure:kPa];
            break;
        default:
            NSLog(@"getOBDBarometricPressure Failed!!");
            break;
    }
    return bp;
}
@end
