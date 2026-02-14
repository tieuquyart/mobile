//
//  NSUserDefaults+Hachi.m
//  Hachi
//
//  Created by lzhu on 3/24/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSUserDefaults+Hachi.h"

@implementation NSUserDefaults (Hachi)

+ (NSString*) visitedKey {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:(__bridge NSString*)kCFBundleVersionKey];
    return [NSString stringWithFormat:@"visitedTimes_%@", version];
}

+ (NSUInteger) visitedTimes {
    return (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:[self visitedKey]];
}

+ (void) visitAgain {
    [[NSUserDefaults standardUserDefaults] setInteger:[self visitedTimes]+1 forKey:[self visitedKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) setAdministrationRight:(NSNumber *)right {
    [[NSUserDefaults standardUserDefaults] setObject:right forKey:@"com.waylens.admin.right"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSNumber*) administrationRight {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"com.waylens.admin.right"];
}

+ (BOOL) cameraStatusInfoHidden {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"com.waylens.camera.status.info.hidden"];
}
+ (void) setCameraStatusInfoHidden:(BOOL)hidden {
    [[NSUserDefaults standardUserDefaults] setBool:hidden forKey:@"com.waylens.camera.status.info.hidden"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@implementation NSUserDefaults(Settings_General)

+ (NSString*) whoCanSeeMyShares {
    NSString *result = [[NSUserDefaults standardUserDefaults] stringForKey:@"whoCanSeeMyShares"];
    return result ?: @"Everyone";
}
+ (void) setWhoCanSeeMyShares:(NSString*)who {
    [[NSUserDefaults standardUserDefaults] setObject:who forKey:@"whoCanSeeMyShares"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) shouldRecordCamceraGPS {
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouldRecordCamceraGPS"];
    return result? result.boolValue : YES;
}
+ (void) setShouldRecordCamceraGPS:(BOOL)record {
    [[NSUserDefaults standardUserDefaults] setBool:record forKey:@"shouldRecordCamceraGPS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) showMyProfileInPublic {
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"showMyProfileInPublic"];
    return result? result.boolValue : YES;
}
+ (void) setShowMyProfileInPublic:(BOOL)show {
    [[NSUserDefaults standardUserDefaults] setBool:show forKey:@"showMyProfileInPublic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) shouldPlayHDOnWiFiOnly {
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouldPlayHDOnWiFiOnly"];
    return result? result.boolValue : NO;
}
+ (BOOL) shouldUploadViaWiFiOnly {
    NSNumber *result = [[NSUserDefaults standardUserDefaults] objectForKey:@"shouldUploadViaWiFiOnly"];
    return result? result.boolValue : YES;
}
+ (NSString*) autoplayOption {
    NSString *result = [[NSUserDefaults standardUserDefaults] stringForKey:@"autoplayOption"];
    return result ?: @"On Wi-Fi Connected Only";
}

+ (void) setShouldPlayHDOnWiFiOnly:(BOOL)only {
    [[NSUserDefaults standardUserDefaults] setBool:only forKey:@"shouldPlayHDOnWiFiOnly"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void) setShouldUploadViaWiFiOnly:(BOOL)only {
    [[NSUserDefaults standardUserDefaults] setBool:only forKey:@"shouldUploadViaWiFiOnly"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void) setAutoplayOption:(NSString*)option {
    [[NSUserDefaults standardUserDefaults] setObject:option forKey:@"autoplayOption"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation NSUserDefaults(Test)

+ (void) setForFirstVisited {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[self visitedKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) clearAdminRight {
    [self setAdministrationRight:nil];
}

@end
