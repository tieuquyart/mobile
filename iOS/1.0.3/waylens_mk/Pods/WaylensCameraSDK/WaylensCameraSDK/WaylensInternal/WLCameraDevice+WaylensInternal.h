//
//  WLCameraDevice+WaylensInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/11/6.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>

@interface WLCameraDevice(WaylensInternal)

////connection

@property (nonatomic, assign, readonly) WLWiFiMode wifiMode;      //0:AP, 1:Client, 2: Off
@property (nonatomic, strong, readonly, nonnull) NSMutableArray *wifiHostList;
@property (nonatomic, assign, readonly) NSUInteger wifiHostNum;
@property (nonatomic, assign, readonly) BOOL isSupportBluetooth;
// read properties blow after BT State changed
@property (nonatomic, strong, readonly, nullable) NSString *obdBindDeviceMac;
@property (nonatomic, strong, readonly, nullable) NSString *obdBindDeviceName;
@property (nonatomic, strong, readonly, nullable) NSString *hidBindDeviceMac;
@property (nonatomic, strong, readonly, nullable) NSString *hidBindDeviceName;
@property (nonatomic, strong, readonly, nullable) NSMutableArray *obdHostList;
@property (nonatomic, strong, readonly, nullable) NSMutableArray *hidHostList;
@property (nonatomic, strong, readonly, nullable) NSMutableArray *otherBluetoothList;
@property (nonatomic, assign, readonly) NSUInteger bluetoothHostNum;

@property (nonatomic, assign, readonly) int bluetoothScanState;   //0. idle; 1. ing; 2. done; 3. getListDone; -1: failed; -2: need reboot
@property (nonatomic, assign, readonly) WLBluetoothStatus obdConnectState;
@property (nonatomic, assign, readonly) WLBluetoothStatus hidConnectState;
@property (nonatomic, assign, readonly) BOOL isBluetoothOpen;

@property (nonatomic, strong, readonly, nullable) NSArray *qualityList;
@property (nonatomic, assign) WLVideoQuality quality;
@property (nonatomic, assign) WLVideoQuality subQuality;

@property (nonatomic, strong, readonly, nullable) NSString *apn;
@property (nonatomic, assign, readonly) BOOL isSupportWlanMode;
@property (nonatomic, assign, readonly) BOOL isSupportRiskDriveEvent;
@property (nonatomic, assign, readonly) BOOL isSubStreamOnly;

- (void)updateHostNum;
- (void)updateHostInfo:(int)index;
- (void)addHost:(nonnull NSString *)name password:(nonnull NSString *)pwd;
- (void)removeHost:(nonnull NSString *)name;
- (void)setWifiMode:(int)mode toSSID:(nullable NSString *)ssid;
- (void)connectToSSID:(nonnull NSString *)ssid;

- (void)doBluetoothOpen:(BOOL)open;
- (void)doBluetoothScan;
- (void)doOBDBind:(nonnull NSString *)mac;
- (void)doHIDBind:(nullable NSString *)mac;
- (void)doOBDUnBind;
- (void)doHIDUnBind;

// api 1.14
- (void)getSupportRiskDriveEvent;
- (void)setSupportRiskDriveEvent:(BOOL)supported;
- (void)doGetAPN;
- (void)doSetAPN:(nonnull NSString *)apn;
- (void)getSupportWlanMode;
- (void)doGetSubStreamOnly;
- (void)doSetSubStreamOnly:(BOOL)isOnly;
- (void)doGetQuality;
// api 1.14 done

- (void)doDebugProps:(BOOL)setOrGet prop:(nonnull NSString *)prop action:(nonnull NSString *)action value:(nonnull NSString *)value key:(nonnull NSString *)key;

- (void)notifyUpdate;

@end
