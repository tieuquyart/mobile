//
//  WLFirmwareUpgradeManager+FrameworkInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/30.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>

@interface WLFirmwareUpgradeManager(FrameworkInternal)

- (BOOL)canUpgradeFromAppForHardware:(NSString *)hw firmware:(NSString *)fw;
- (BOOL)checkforDevice:(WLCameraDevice *)camera;
- (WLFirmwareStatus)checkFirmwareStatusFor:(NSString *)Hw;

- (long)sizeofNewFirmwareFromCamera:(WLCameraDevice *)camera;
- (int)doCheckSpace:(int)MB forCamera:(WLCameraDevice *)camera;//return need xMB. -1 for error, 0 for OK

@end

@protocol FwInforDelegate <NSObject>
@optional
- (void)FwDownloading:(int)process downloaded:(long)size forHw:(NSString *)hw;
- (void)FwServerCannotAccessforHw:(NSString *)hw;
- (void)FwDownloadErrorforHw:(NSString *)hw;
@end

@interface WLFirmwareInfo(FrameworkInternal)

- (id)initWithHw:(NSString *)hw Fw:(NSString *)fw Url:(NSString *)url;
- (NSDictionary*)generateDictionaryObject;
- (NSString *)getBSPVersion;
- (NSDictionary*)getUpgradeDescription;
- (void)updateUpgradeDescription:(NSDictionary*)desc;
- (BOOL)CanUpgradeFromAppForVersion:(NSString *)fw;
- (BOOL)isNotSameWith:(NSDictionary*)fw;
- (BOOL)isNewVersion:(NSString *)newFw;
- (int)CheckAccessable;
- (void)setStatus:(WLFirmwareStatus)sta;
- (void)setLocalFWFile:(NSString *)file;
- (NSString *)getLocalFWFile;
- (NSString *)getFWmd5;
- (void)DownloadFromServer:(BOOL)must;
- (void)DeleteLocalFW;
- (void)stopDownloading;

- (void)onEnterForeground;
- (void)onEnterBackground;

- (BOOL)isFromExternal;
- (double)downloadDate;

@end
