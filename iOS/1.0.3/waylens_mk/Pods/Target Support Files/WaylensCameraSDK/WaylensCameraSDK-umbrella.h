#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CDevice.h"
#import "SecurityEvent.h"
#import "WLCameraVDBClient.h"
#import "WLCameraVDBClipsAgent.h"
#import "WLVDBClip.h"
#import "WLVDBThumbnail.h"
#import "WLVDBThumbnailCache.h"
#import "WLVDBVideoDownloader.h"
#import "WaylensCameraSDK.h"
#import "WLBonjourCameraListManager.h"
#import "WLCameraClient.h"
#import "WLCameraDevice.h"
#import "WLDefine.h"
#import "WLFirmwareUpgradeManager.h"
#import "WLSocketClient.h"
#import "WLCameraDevice+WaylensInternal.h"
#import "WLCameraSettingsListItem.h"
#import "WLCameraVDBClient+WaylensInternal.h"
#import "WLDmsClient.h"
#import "WLVDBClip+WaylensInternal.h"

FOUNDATION_EXPORT double WaylensCameraSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char WaylensCameraSDKVersionString[];

