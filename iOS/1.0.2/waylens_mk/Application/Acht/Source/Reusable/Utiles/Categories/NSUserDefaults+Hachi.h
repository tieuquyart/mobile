//
//  NSUserDefaults+Hachi.h
//  Hachi
//
//  Created by lzhu on 3/24/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Hachi)

+ (NSUInteger) visitedTimes;
+ (void) visitAgain;

+ (void) setAdministrationRight:(NSNumber*)right;
+ (NSNumber*) administrationRight;

+ (BOOL) cameraStatusInfoHidden;
+ (void) setCameraStatusInfoHidden:(BOOL)hidden;

@end


@interface NSUserDefaults (Settings_General)

//settings-general-privacy
+ (NSString*) whoCanSeeMyShares;
+ (void) setWhoCanSeeMyShares:(NSString*)who;

+ (BOOL) shouldRecordCamceraGPS;
+ (void) setShouldRecordCamceraGPS:(BOOL)record;

+ (BOOL) showMyProfileInPublic;
+ (void) setShowMyProfileInPublic:(BOOL)show;

+ (BOOL) shouldPlayHDOnWiFiOnly;
+ (BOOL) shouldUploadViaWiFiOnly;
+ (NSString*) autoplayOption;

+ (void) setShouldPlayHDOnWiFiOnly:(BOOL)only;
+ (void) setShouldUploadViaWiFiOnly:(BOOL)only;
+ (void) setAutoplayOption:(NSString*)option;

@end

@interface NSUserDefaults (Test)

+ (void) setForFirstVisited;

+ (void) clearAdminRight;

@end

