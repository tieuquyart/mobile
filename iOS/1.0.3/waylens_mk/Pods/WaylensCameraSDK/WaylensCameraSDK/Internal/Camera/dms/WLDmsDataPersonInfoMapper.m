//
//  WLDmsDataPersonInfoMapper.m
//  WaylensCameraSDK
//
//  Created by forkon on 2021/4/7.
//  Copyright © 2021 Waylens. All rights reserved.
//

#import "WLDmsDataPersonInfoMapper.h"
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>

@implementation WLDmsDataPersonInfoMapper

+ (NSDictionary *)mapWithHeader:(eyesight_dms_data_header_t *)header personInfo:(eyesight_person_info_t *)personInfo {
    NSMutableDictionary *dmsDict = [[NSMutableDictionary alloc] initWithDictionary:@{}];

    if (header->flags & EYESIGHT_DATA_F_L1_HAS_PERSON_ID) {
        [dmsDict setObject:[NSString stringWithFormat:@"%s", personInfo->name] forKey:@(WLDmsDataKeysDriverName)];
    }

    return dmsDict;
}

@end
