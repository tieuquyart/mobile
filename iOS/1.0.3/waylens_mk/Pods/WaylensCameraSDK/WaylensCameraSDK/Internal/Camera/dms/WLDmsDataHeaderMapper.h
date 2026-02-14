//
//  WLDmsDataHeaderMapper.h
//  WaylensCameraSDK
//
//  Created by forkon on 2021/4/7.
//  Copyright © 2021 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface WLDmsDataHeaderMapper : NSObject

+ (NSDictionary *)mapWithHeader:(eyesight_dms_data_header_t *)header;

@end

NS_ASSUME_NONNULL_END
