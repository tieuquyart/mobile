//
//  WaylensCameraSDK.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/8/27.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for WaylensCameraSDK.
FOUNDATION_EXPORT double WaylensCameraSDKVersionNumber;

//! Project version string for WaylensCameraSDK.
FOUNDATION_EXPORT const unsigned char WaylensCameraSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WaylensCameraSDK/PublicHeader.h>

#import "WLDefine.h"
#import "WLBonjourCameraListManager.h"
#import "WLCameraDevice.h"
#import "WLCameraClient.h"
#import "WLSocketClient.h"
#import "CDevice.h"
#import "SecurityEvent.h"
#import "WLFirmwareUpgradeManager.h"

// Video Database
#import "WLVDBClip.h"
#import "WLVDBThumbnail.h"
#import "WLCameraVDBClient.h"
#import "WLCameraVDBClipsAgent.h"
#import "WLVDBVideoDownloader.h"
#import "WLVDBThumbnailCache.h"
