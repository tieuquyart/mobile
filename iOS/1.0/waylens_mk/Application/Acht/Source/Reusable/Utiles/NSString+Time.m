//
//  NSString.m
//  Hachi
//
//  Created by gliu on 16/3/14.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import "NSString+Time.h"

@implementation NSString (Time)

+ (NSString*)stringWithTime:(NSTimeInterval)seconds {
    NSString* str = nil;
    seconds += 0.5;
    if (seconds < 0) {
        seconds = 0;
    }
    if (seconds < 3600) {
        int min = seconds / 60;
        str = [NSString stringWithFormat:@"%02d:%02.0f", min, floorf(seconds - min*60)];
    } else {
        int hour = seconds / 3600;
        int min = (seconds - 3600 * hour) / 60;
        str = [NSString stringWithFormat:@"%d:%02d:%02.0f", hour, min, floorf(seconds - hour*3600 - min*60)];
    }
    return str;
}
@end
