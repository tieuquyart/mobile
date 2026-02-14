//
//  WLFirmwareUpgradeManager.h
//  Vidit
//
//  Created by gliu on 14-9-16.
//  Copyright (c)2014年 Transee Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLCameraDevice.h"

typedef NS_ENUM(int, WLFirmwareStatus) {
    WLFirmwareStatusIdle = 0,
    WLFirmwareStatusDownloading,
    WLFirmwareStatusDownloaded,
    WLFirmwareStatusFailed,
    WLFirmwareStatusNotFound
};


@interface WLFirmwareInfo: NSObject <NSURLConnectionDelegate>

- (id)initWithDictionary:(NSDictionary*)dict;

- (NSString *)getLatestFirmwareVersion;
- (NSString *)getLatestAPIVersion;
- (NSString *)getLocalizedUpgradeDescription;
- (long)getFirmwareSize;
- (NSString *)getHardwareVersion;
- (WLFirmwareStatus)getStatus;
- (BOOL)needUpgrade:(NSString *)currentFirmwareVersion;
- (NSString *)downloadUrl;

@end


@protocol WLFirmwareUpgradeManagerDelegate;

@interface WLFirmwareUpgradeManager: NSObject

@property (strong, nonatomic) NSString *server;

+ (instancetype)sharedManager;

- (void)addDelegate:(id<WLFirmwareUpgradeManagerDelegate>)delegate;
- (void)removeDelegate:(id<WLFirmwareUpgradeManagerDelegate>)delegate;

- (void)addCamera:(WLCameraDevice *)camera;
- (void)removeCamera:(WLCameraDevice *)camera;

- (NSString *)basePath;

- (void)resetLocalFiles;

// For ToB Camera.
- (void)saveFirmwareInfo:(WLFirmwareInfo *)fwInfo;
- (void)downloadFirmwareForInfo:(WLFirmwareInfo *)fwInfo;
- (WLFirmwareInfo *)firmwareInfoForModel:(NSString *)model bspVersion:(NSString *)bspVersion;
- (void)doUpgradeForCamera:(WLCameraDevice *)camera withFirmwareInfo:(WLFirmwareInfo *)fwInfo;

// For ToC Camera.
- (WLFirmwareInfo *)firmwareInfoForModel:(NSString *)model;
- (void)downloadFirmwareForHardware:(NSString *)Hw;
- (void)checkFromServer;
- (BOOL)isUpgradingCamera:(WLCameraDevice *)camera;
- (void)doUpgradeForCamera:(WLCameraDevice *)camera;
- (void)downloadExternalFirmwareFromUrl:(NSString *)url;
- (void)removeExternalFirmware;
- (BOOL)isExternalFirmwareValid;

@end


@protocol WLFirmwareUpgradeManagerDelegate <NSObject>
@optional
- (void)firmwareUpgradeManager:(WLFirmwareUpgradeManager *)firmwareUpgradeManager firmwareCheckDone:(BOOL)done;
- (void)firmwareUpgradeManager:(WLFirmwareUpgradeManager *)firmwareUpgradeManager firmwareDownloading:(int)process downloaded:(long)size forHardware:(NSString *)hw;
- (void)firmwareUpgradeManager:(WLFirmwareUpgradeManager *)firmwareUpgradeManager firmwareServerCannotAccessforHardware:(NSString *)hw;
- (void)firmwareUpgradeManager:(WLFirmwareUpgradeManager *)firmwareUpgradeManager firmwareDownloadErrorForHardware:(NSString *)hw;
- (void)firmwareUpgradeManagerTooManyTasks:(WLFirmwareUpgradeManager *)firmwareUpgradeManager;
- (void)firmwareUpgradeManager:(WLFirmwareUpgradeManager *)firmwareUpgradeManager sendFirmwareToCamera:(WLCameraDevice *)camera process:(int)process;
- (void)firmwareUpgradeManager:(WLFirmwareUpgradeManager *)firmwareUpgradeManager sendFirmwareToCamera:(WLCameraDevice *)camera finish:(BOOL)finished;
@end
