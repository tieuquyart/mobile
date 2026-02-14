//
//  WLDmsDataMapperV3.h
//  WaylensCameraSDK
//
//  Created by forkon on 2021/4/7.
//  Copyright © 2021 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutputInternal.h"
#import "WLDefine.h"
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLDmsDataMapperV3 : NSObject

+ (WLDmsData *)mapWithHeader:(eyesight_dms_data_header_t *)header output:(L1OutputAll_1_3 *)output personInfo:(nullable eyesight_person_info_t *)personInfo;

@end

NS_ASSUME_NONNULL_END
