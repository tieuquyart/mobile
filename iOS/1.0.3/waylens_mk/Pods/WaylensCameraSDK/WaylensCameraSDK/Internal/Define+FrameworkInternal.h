//
//  VDBClasses.h
//  Vidit
//
//  Created by gliu on 15/1/13.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kWaylensServiceTypeEvcam @"_evcam._tcp."
#define kWaylensServiceTypeCamClient @"_ccam._tcp."
#define kInitialDomain  @"local"

#define BTNameKey  "BTNameKey"
#define BTMacKey   "BTMacKey"

static inline double sTimeFloat(UInt32 hi, UInt32 low) {
    UInt64 rt = 0;
    rt = hi;
    rt = rt << 32;
    rt += low;
    double r = rt;
    return r/1000.0;
}
static inline uint32_t sTimeHi(double t) {
    UInt64 rt = t * 1000;
    return rt >> 32;
}
static inline uint32_t sTimeLo(double t) {
    UInt64 rt = t * 1000;
    return (uint32_t)(rt & 0xffffffff);
}

#define MAKE_FOURCC(a, b, c, d) (((uint32_t)(d)) | (((uint32_t)(c)) << 8) | (((uint32_t)(b)) << 16) | (((uint32_t)(a)) << 24))
#define MAKE_FOURCC_STR( str ) MAKE_FOURCC( str[0], str[1], str[2], str[3])
