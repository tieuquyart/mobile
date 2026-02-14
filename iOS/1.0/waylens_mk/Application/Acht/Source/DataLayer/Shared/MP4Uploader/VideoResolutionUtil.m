//
//  VideoResolutionUtil.m
//  Hachi
//
//  Created by Waylens Administrator on 11/25/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "VideoResolutionUtil.h"

@implementation VideoResolutionUtil

+(MP4Resolution)resolutionTypeForHeight:(float)height width:(float)width{
    float h = MIN(height, width);
    if (width == height) { // Video from Secure360 camera.
        return MP4Resolution360P;
    } else if (h>=2160) {
        return MP4Resolution4K;
    } else if (h>=1080) {
        return MP4Resolution1080P;
    } else if (h>=720) {
        return MP4Resolution720P;
    } else if (h>=480) {
        return MP4Resolution480P;
    } else{
        return MP4Resolution360P;
    }
}

+(NSString *)resolutionStringForType:(MP4Resolution)resolution{
    if (resolution==MP4Resolution4K) {
        return @"4K";
    } else if (resolution==MP4Resolution1080P) {
        return @"1080P";
    } else if (resolution==MP4Resolution720P) {
        return @"720P";
    } else if (resolution==MP4Resolution480P) {
        return @"480P";
    } else if (resolution==MP4Resolution360P){
        return @"360P";
    } else {
        return @"HD";
    }
}

+(NSString *)resolutionStringForHeight:(float)height width:(float)width{
    MP4Resolution resolution = [self resolutionTypeForHeight:height width:width];
    return [self resolutionStringForType:resolution];
}

@end
