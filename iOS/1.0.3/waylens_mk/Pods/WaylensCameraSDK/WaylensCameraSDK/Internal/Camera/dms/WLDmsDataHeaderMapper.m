//
//  WLDmsDataHeaderMapper.m
//  WaylensCameraSDK
//
//  Created by forkon on 2021/4/7.
//  Copyright © 2021 Waylens. All rights reserved.
//

#import "WLDmsDataHeaderMapper.h"
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>

@implementation WLDmsDataHeaderMapper

+ (NSDictionary *)mapWithHeader:(eyesight_dms_data_header_t *)header {
    NSMutableDictionary *dmsDict = [[NSMutableDictionary alloc] initWithDictionary:@{}];

    [dmsDict setObject:@(header->isDriverValid) forKey:@(WLDmsDataKeysIsDriverValid)];
    [dmsDict setObject:[NSValue valueWithCGSize:CGSizeMake(header->dms_width, header->dms_height)] forKey:@(WLDmsDataKeysResolution)];
    [dmsDict setObject:[NSValue valueWithCGPoint:CGPointMake(header->input_xoff, header->input_yoff)] forKey:@(WLDmsDataKeysInputOffset)];
    [dmsDict setObject:[NSValue valueWithCGSize:CGSizeMake(header->input_width, header->input_height)] forKey:@(WLDmsDataKeysInputResolution)];
    [dmsDict setObject:[NSValue valueWithCGSize:CGSizeMake(header->src_width, header->src_height)] forKey:@(WLDmsDataKeysSrcResolution)];

    return dmsDict;
}

@end
