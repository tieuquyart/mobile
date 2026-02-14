//
//  WLDmsDataMapperV6.h
//  WaylensCameraSDK
//
//  Created by forkon on 2021/4/7.
//  Copyright © 2021 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "DriverSenseEngineV6.h"
#import "WLDefine.h"
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>

typedef struct ds_v6::L1Output L1OutputV6;

NS_ASSUME_NONNULL_BEGIN

@interface WLDmsDataMapperV6 : NSObject

+ (WLDmsData *)mapWithHeader:(eyesight_dms_data_header_t *)header output:(L1OutputV6 *)output personInfo:(nullable eyesight_person_info_t *)personInfo;

@end

NS_ASSUME_NONNULL_END
