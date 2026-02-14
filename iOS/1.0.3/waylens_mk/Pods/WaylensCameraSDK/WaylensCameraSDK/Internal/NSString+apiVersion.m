//
//  NSString+apiVersion.m
//  Hachi
//
//  Created by Waylens Administrator on 10/14/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSString+apiVersion.h"

@implementation NSString (apiVersion)
-(NSComparisonResult)compareWithVersion:(NSString *)version{
    NSArray *a = [self componentsSeparatedByString:@"."];
    NSArray *b = [version componentsSeparatedByString:@"."];
    NSUInteger la = a.count>b.count?b.count:a.count;
    for (int i=0; i<la; i++) {
        if ([a[i] intValue]>[b[i] intValue]) {
            return NSOrderedDescending;
        }
        if ([a[i] intValue]<[b[i] intValue]) {
            return NSOrderedAscending;
        }
    }
    return NSOrderedSame;
}

@end
