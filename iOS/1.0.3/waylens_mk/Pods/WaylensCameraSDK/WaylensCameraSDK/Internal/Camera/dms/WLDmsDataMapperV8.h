//
//  WLDmsDataMapperV8.h
//  WaylensCameraSDK
//
//  Created by forkon on 2021/4/7.
//  Copyright © 2021 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "DriverSenseEngineV8.h"
#import "WLDefine.h"
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>

typedef struct ds_v8::L1Output L1OutputV8;

NS_ASSUME_NONNULL_BEGIN

@interface WLDmsDataMapperV8 : NSObject

+ (WLDmsData *)mapWithHeader:(eyesight_dms_data_header_t *)header output:(L1OutputV8 *)output personInfo:(nullable eyesight_person_info_t *)personInfo;

@end

NS_ASSUME_NONNULL_END
