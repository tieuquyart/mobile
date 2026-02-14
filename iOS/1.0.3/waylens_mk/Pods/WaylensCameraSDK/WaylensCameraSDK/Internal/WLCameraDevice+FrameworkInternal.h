//
//  WLCameraDevice+Private.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/25.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WLCameraDeviceDelegate <CDeviceDelegate>
- (void)onDevice:(id)dev NameChanged:(NSString*)name;
- (void)onDeviceUpdated:(id)dev;
- (void)onDevice:(id)dev recTime:(double)sec;
- (void)onDevice:(id)dev recErr:(NSError*)err;
- (void)onLiveMark:(BOOL)done;
@end

@interface WLCameraDevice(FrameworkInternal)
@property (nonatomic, weak) id<WLCameraDeviceDelegate> delegate;
@property (nonatomic, assign, readonly) WLCommunicationProtocolVersion communicationProtocolVersion;

- (instancetype)initWithIPv4:(NSString*)ipv4 IPv6:(NSString*)ipv6 port:(long)port isCamera:(BOOL)isCamera;

- (void)connect;
- (void)disconnect;

- (void)becomeActive;
- (void)resignActive;

- (void)setStream:(BOOL)bBigStream; //for preview

- (void)newFirmwareWithMD5:(NSString *)md5;
- (void)upgradeFirmware;

- (void)setNeedUpgrade:(BOOL)need withAPIVersion:(NSString *)apiVersion andBSPVersion:(NSString *)bspVersion andDescription:(NSDictionary *)description;

@end

NS_ASSUME_NONNULL_END
