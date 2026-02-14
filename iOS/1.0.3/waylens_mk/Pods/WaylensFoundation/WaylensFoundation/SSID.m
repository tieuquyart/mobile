//
//  SSID.m
//  Hachi
//
//  Created by lzhu on 8/2/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "SSID.h"
#import "SystemConfiguration/CaptiveNetwork.h"
#import "NSString+Extension.h"

static NSArray* FetchSSIDs() {
    CFArrayRef ifs = CNCopySupportedInterfaces();
    NSArray *array = CFBridgingRelease(ifs);
    NSMutableArray *ssids = [NSMutableArray array];
    for(NSString *ifnam in array) {
        CFDictionaryRef info = CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSDictionary *dic = CFBridgingRelease(info);
        if(dic) {
            NSString *ssid = [dic objectForKey:@"SSID"];
            if(![NSString isNullOrEmpty:ssid]) {
                [ssids addObject:ssid];
            }
        }
        
    }
    NSLog(@"Find SSID : %@", ssids.count > 0? ssids[0] : @"NONE");
    return ssids;
}

@implementation SSID

+ (NSArray*) fetchSSIDs {
    return FetchSSIDs();
}

+ (NSString *)currentSSID {
    NSArray *ssids = [self fetchSSIDs];
    if (ssids.count == 0) {
        return nil;
    }
    return ssids[0];
}

@end
