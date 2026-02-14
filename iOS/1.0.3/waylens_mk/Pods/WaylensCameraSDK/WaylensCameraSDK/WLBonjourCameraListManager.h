//
//  DeviceManager.h
//  Vidit
//
//  Created by gliu on 15/1/6.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import "WLCameraDevice.h"
#import "WLDefine.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const WLCurrentCameraChangeNotification; // current camera changed notification

@protocol WLBonjourCameraListManagerDelegate;

@interface WLBonjourCameraListManager: NSObject

@property (class, readonly, strong) WLBonjourCameraListManager *sharedManager;

/// The connected camera which is selected, default is the first camera in list of the connected cameras, nil if not connected.
@property (nonatomic, readonly, nullable) WLCameraDevice *currentCamera;

/// The Wi-Fi that the i-device connected, nil if not connected.
@property (nonatomic, readonly, nullable) NSString *currentWiFi;

/// The list of the connected cameras.
@property (nonatomic, readonly) NSArray<WLCameraDevice *> *cameraList;

/// A Boolean value indicating whether the SSID of the current Wi-Fi contains "Waylens", or if cannot get the Wi-Fi's SSID, indicating whether has discovered camera with specific IP.
/// Doesn't mean that the camera has been connected.
@property (nonatomic, assign, readonly) BOOL hasConnectedCameraWiFi;

/// Start cameras discovery service.
/// Recommend call this method just after the application did become active.
/// After activation, you can observe the change of the current camera, camera list, etc., through notification or delegate.
- (void)activate;
- (void)deactivate;

- (void)addDelegate:(id<WLBonjourCameraListManagerDelegate>)delegate NS_SWIFT_NAME(add(delegate:));
- (void)removeDelegate:(id<WLBonjourCameraListManagerDelegate>)delegate NS_SWIFT_NAME(remove(delegate:));

@end

@protocol WLBonjourCameraListManagerDelegate <NSObject>
/// Tells the delegate that the list of the connected cameras has changed.
- (void)bonjourCameraListManager:(WLBonjourCameraListManager *)bonjourCameraListManager didUpdateCameraList:(NSArray<WLCameraDevice *> *)cameraList;
- (void)bonjourCameraListManager:(WLBonjourCameraListManager *)bonjourCameraListManager didDisconnectCamera:(WLCameraDevice *)camera;

@optional

- (void)bonjourCameraListManager:(WLBonjourCameraListManager *)bonjourCameraListManager didUpdateCamera:(WLCameraDevice *)camera;

/// Tells the delegate that the live video stream has been marked.
- (void)bonjourCameraListManager:(WLBonjourCameraListManager *)bonjourCameraListManager didLiveMark:(BOOL)done;

/// Tells the delegate that the i-device has connected to a different Wi-Fi.
- (void)bonjourCameraListManager:(WLBonjourCameraListManager *)bonjourCameraListManager didChangeNetwork:(nullable NSString *)ssid;

/// Tells the delegate that there's a camera's name has changed.
- (void)bonjourCameraListManager:(WLBonjourCameraListManager *)bonjourCameraListManager camera:(WLCameraDevice *)camera didChangeName:(nullable NSString *)name;

/// Tells the delegate that the camera encountered an error during recording.
- (void)bonjourCameraListManager:(WLBonjourCameraListManager *)bonjourCameraListManager camera:(WLCameraDevice *)camera didEncounterRecError:(NSError *)err;

@end

NS_ASSUME_NONNULL_END
