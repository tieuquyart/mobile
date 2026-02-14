//
//  WLDmsDataPersonInfoMapper.h
//  WaylensCameraSDK
//
//  Created by forkon on 2021/4/7.
//  Copyright © 2021 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLDmsDataPersonInfoMapper : NSObject

+ (NSDictionary *)mapWithHeader:(eyesight_dms_data_header_t *)header personInfo:(eyesight_person_info_t *)personInfo;

@end

NS_ASSUME_NONNULL_END
