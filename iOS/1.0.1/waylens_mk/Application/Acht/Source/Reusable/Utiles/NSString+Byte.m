//
//  NSString+Byte.m
//  Hachi
//
//  Created by Waylens Administrator on 8/12/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSString+Byte.h"

@implementation NSString(Byte)
+ (NSString *)stringFromByteCount:(NSNumber *)value {
    double count = [value doubleValue];
    NSArray *units = @[@"bytes", @"KB", @"MB", @"GB"];
    NSArray *formats = @[@"%.0f %@", @"%.1f %@", @"%.2f %@"];
    int scale = 0;
    while (count > 1000) {
        count /= 1000;
        if (scale+1==units.count) {
            break;
        }
        scale += 1;
    }
    int w = scale;
    if (count>100) {
        w -= 3;
    } else if (count>10) {
        w -= 2;
    } else if (count>1) {
        w -= 1;
    }
    if (w < 0) {
        w = 0;
    }
    if (w >= formats.count) {
        w = (int)formats.count - 1;
    }
    return [NSString stringWithFormat:formats[w], count, units[scale]];
}

@end
