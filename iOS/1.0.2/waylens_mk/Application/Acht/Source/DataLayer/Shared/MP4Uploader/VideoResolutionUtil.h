//
//  VideoResolutionUtil.h
//  Hachi
//
//  Created by Waylens Administrator on 11/25/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum MP4Resolution {
    MP4ResolutionHD     =   0,
    MP4Resolution1080P  =   1,
    MP4Resolution720P   =   2,
    MP4Resolution480P   =   4,
    MP4Resolution360P   =   8,
    MP4Resolution4K     =   16
} MP4Resolution;

@interface VideoResolutionUtil : NSObject
+(MP4Resolution)resolutionTypeForHeight:(float)height width:(float)width;
+(NSString *)resolutionStringForHeight:(float)height width:(float)width;
+(NSString *)resolutionStringForType:(MP4Resolution)resolution;
@end
