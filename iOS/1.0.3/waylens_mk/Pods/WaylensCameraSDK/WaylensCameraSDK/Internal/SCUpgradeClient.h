//
//  SCUpgradeClient.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/30.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLCameraDevice.h"

@class SCUpgradeClient;
@protocol UpgCliDelegate <NSObject>
@optional
- (void)RdyToUpgradeforCamera:(SCUpgradeClient*)camera;
- (void)GoonUpgradeforCamera:(SCUpgradeClient*)camera;
- (void)UpgradeDoneforCamera:(SCUpgradeClient*)camera;
- (void)UpgradeFailedforCamera:(SCUpgradeClient*)camera;
- (void)Upgradeprocess:(int)process Camera:(SCUpgradeClient*)camera;
@end

@interface SCUpgradeClient : NSObject <WLCameraFirmwareUpgradeDelegate, NSStreamDelegate> {
    WLCameraDevice *_pdevice;
    NSString* sn;
    long long SDFreeSpace;
    int       BatteryLevel;
    NSString* myip;
    int       port;
    NSString* localfile;
    NSInputStream* inputStream;
    NSOutputStream* outputStream;
    BOOL    bUpgrading;
    NSFileHandle *pFileHandle;
    unsigned long long offset;
    unsigned long long filesize;
}
- (id)initWithCamera:(WLCameraDevice *)camera;
- (void)updateInfo;
- (void)updateCamera:(WLCameraDevice *)camera;
- (WLCameraDevice *)getDevice;
- (void)sendFWtoCamera:(NSString *)file md5:(NSString *)md5;
- (BOOL)isUpgrading;
- (void)done:(BOOL)done;
- (void)startDoUpgrade;
- (void)cancel;

@property (strong, nonatomic)  NSString* pCameraID;
@property (strong, nonatomic)  NSString* pHwVersion;
@property (strong, nonatomic)  NSString* pCurrentFwVersion;
@property (weak, nonatomic)    id<UpgCliDelegate>   cliDele;
@end
