//
//  WLCameraDevice.h
//  Vidit
//
//  Created by gliu on 15/1/7.
//  Copyright (c) 2015年 Transee. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CDevice.h"
#import "WLDefine.h"
#import "WLCameraVDBClient.h"
#import "WLCameraVDBClipsAgent.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WLProductSerie) {
    WLProductSerieUnknown,
    WLProductSerieHachi,
    WLProductSerieHorn,
    WLProductSerieSaxhorn,
    WLProductSerieSecureES
};

@protocol WLCameraFirmwareUpgradeDelegate <NSObject>

- (void)onReadyToUpgrade;
- (void)onUpgradeResult:(int)process;

//Evcam
- (void)onTransferFirmware:(int)state size:(int)firmwareSize progress:(int)progress errorCode:(int)errorCode;

@end


@protocol WLCameraSettingsDelegate <NSObject>

@optional

- (void)onFormatTFCard:(BOOL)success;
- (void)onFactoryReset:(BOOL)success;
- (void)onGetPassword:(nullable NSString *)password;
- (void)onGetMountConfig:(nullable NSDictionary *)config;
- (void)onGetHDRMode:(WLCameraHDRMode)mode;

// api 1.9
- (void)onGetMountAccelLevels:(nullable NSArray *)levels current:(nullable NSString *)current;
- (void)onSetMountAccelLevel:(BOOL)result;

// for debug
- (void)onGetMountAccelParam:(nullable NSString *)param;
- (void)onSetMountAccelParam:(BOOL)result;

- (void)onGetMarkStorageOptions:(nullable NSArray *)levels current:(int)currentInGB;
- (void)onSetMarkStorage:(int)gb;
- (void)onGetAudioPromptEnabled:(BOOL)enabled;
// api 1.9 end

// api 1.10
- (void)onGetLTEStatus:(nullable NSDictionary *)status;
- (void)onGetICCID:(nullable NSString *)iccid;
- (void)onGetRadarSensitivity:(float)level;
- (void)onSetRadarSensitivity:(float)level;
- (void)onDebugProp:(nullable NSString *)prop value:(nullable NSString *)value;
// api 1.10 done

// api 1.12
- (void)onGetMountACCTrust:(BOOL)trusted;
// api 1.12 done

// api 1.13
- (void)onGetAppKeepAlive:(BOOL)keep;
- (void)onGetSupportUpsideDown:(BOOL)isSupported;
- (void)onGetAttitude:(BOOL)isUpsideDown;
// api 1.13 done

// api 1.14
- (void)onGetSupportRiskDriveEvent:(BOOL)supported;
- (void)onGetAPN:(nullable NSString *)apn;
- (void)onGetSupportWlanMode:(BOOL)supported;
- (void)onGetProtectionVoltage:(int)voltage;
- (void)onGetParkSleepDelay:(int)delaySeconds;
- (void)onGetSubStreamOnly:(BOOL)isOnly;
- (void)onWiFiHostListChanged:(NSArray *)hostList;
- (void)onSetQuality:(BOOL)success;
// api 1.14 done

- (void)ongetBTInfoWithSupported:(BOOL)bSupported
                         enabled:(BOOL)bEnabled
                        scanning:(BOOL)isScanning
                       OBDStatus:(WLBluetoothStatus)obdStatus
                         OBDName:(NSString *)obdName
                          OBDMac:(NSString *)obdMac
                       HIDStatus:(WLBluetoothStatus)hidStatus
                         HIDName:(NSString *)hidName
                          HIDMac:(NSString *)hidMac
                       HIDBatLev:(int)hidBatLev;

// for debug
- (void)onGetIIOEventDetectionParam:(nullable NSString *)param;
- (void)onSetIIOEventDetectionParam:(BOOL)result;

// for tw03
- (void)onSetHotspotInfoWithSsid:(NSString *)ssid andPassword:(NSString *)password;
- (void)onGetConfigSettingMK:(NSDictionary *)mkConfig cmd:(NSString*)cmd;
- (void)onCopyLog:(BOOL)value;
- (void)onCopyDebugLog:(BOOL)value;


@end

@class WLBatteryInfo;
@class WLCameraRecordConfig;
@class WLObdWorkModeConfig;
@class WLAdasConfig;
@class WLAuxConfig;

@interface WLCameraDevice: CDevice

@property (nonatomic, strong, nullable) NSDictionary *TCVN1Config;
@property (nonatomic, strong, nullable) NSDictionary *TCVN2Config;
@property (nonatomic, strong, nullable) NSDictionary *TCVN3Config;
@property (nonatomic, strong, nullable) NSDictionary *TCVN4Config;
@property (nonatomic, strong, nullable) NSDictionary *TCVN5Config;
@property (nonatomic, strong, nullable) NSDictionary *ConfigDriverInfoMK;
@property (nonatomic, strong, nullable) NSDictionary *ConfigSetting_cfgMK;
@property (nonatomic, strong, nullable) NSDictionary *ConfigIn_outMK;

@property (nonatomic, weak, nullable) id<WLCameraFirmwareUpgradeDelegate> firmwareUpgradeDelegate;
@property (nonatomic, weak, nullable) id<WLCameraSettingsDelegate> settingsDelegate;

@property (strong, nonatomic, readonly) WLCameraVDBClient *vdbClient;
@property (strong, nonatomic, readonly) WLCameraVDBClipsAgent *clipsAgent;

@property (nonatomic, assign, readonly) WLProductSerie productSerie;

@property (nonatomic, assign, readonly) BOOL isConnected;

@property (nonatomic, strong, readonly, nullable) NSString *name;
@property (nonatomic, strong, readonly, nullable) NSString *apiVersion;
@property (nonatomic, strong, readonly, nullable) NSString *sn;
@property (nonatomic, strong, readonly, nullable) NSString *firmwareVersion;
@property (nonatomic, strong, readonly, nullable) NSString *hardwareModel;

// Supported Feature

@property (nonatomic, strong, readonly, nullable) NSArray *vinMirrorList;
@property (nonatomic, strong, readonly, nullable) NSArray *recordConfigList;
@property (nonatomic, strong, readonly, nullable) WLCameraRecordConfig *recordConfig;

@property (nonatomic, strong, readonly, nullable) NSString *serverAddress;
@property (nonatomic, strong, readonly, nullable) NSString *password;
@property (nonatomic, strong, readonly, nullable) NSString *mountHardwareModel;
@property (nonatomic, strong, readonly, nullable) NSString *mountFirmwareVersion;
@property (nonatomic, assign, readonly) int mountVersionCode;
@property (nonatomic, assign, readonly) BOOL isSupportRadarSensitivity;
@property (nonatomic, assign, readonly) BOOL isSupport4g;
@property (nonatomic, assign, readonly) BOOL isParking;
@property (nonatomic, assign, readonly) WLCameraHDRMode hdrMode;
@property (nonatomic, strong, readonly, nullable) WLBatteryInfo *batteryInfo;
@property (nonatomic, strong, readonly, nullable) NSDictionary *lteInfo;
@property (nonatomic, strong, readonly, nullable) NSString *iccid;
@property (nonatomic, strong, readonly, nullable) NSString *lteFirmwareVersionPublic;
@property (nonatomic, strong, readonly, nullable) NSString *lteFirmwareVersionInternal;

@property (nonatomic, assign, readonly) int liveMarkBeforeSec; //bookmark duration
@property (nonatomic, assign, readonly) int liveMarkAfterSec;

#pragma mark - properties for KVO

@property (nonatomic, assign, readonly) WLRecordState recState;

@property (nonatomic, strong, readonly, nullable) NSString *accelerometerLevel;

/// Memory card's total capacity in MB.
@property (nonatomic, assign, readonly) int totalMB;

/// Memory card's free capacity in MB.
@property (nonatomic, assign, readonly) int freeMB;

/// Buffered videos usage in MB.
@property (nonatomic, assign, readonly) int clipMB;

/// Event videos usage in MB.
/// Cannot be erased automatically, -1 means unknown.
@property (nonatomic, assign, readonly) int markedMB;

@property (nonatomic, assign, readonly) WLStorageState storageState;

/// If this value has "AGTS" prefix, means the memory card should be format.
@property (nonatomic, strong, readonly, nullable) NSString *format;

@property (nonatomic, assign, readonly) BOOL isCharging;

/// A Boolean value that indicates whether the camera's MIC is enabled.
@property (nonatomic, assign, readonly) BOOL isMute;
@property (nonatomic, assign, readonly) int micLevel;

/// A Boolean value that indicates what decides if the car is driving.
/// `true` means vehicle power, `false` means vehicle movement.
@property (nonatomic, assign, readonly) BOOL isMountACCTrusted;

@property (nonatomic, assign, readonly) BOOL keepAliveIfAppConnected;

/// A Boolean value that indicates whether the camera is installed upside down.
@property (nonatomic, assign, readonly) BOOL isUpsideDown;

/// A Boolean value that indicates whether the camera can be installed upside down.
@property (nonatomic, strong, readonly, nullable) NSNumber *isSupportUpsideDown;

/// An Integer voltage value in mV that decides which battery protection mode shall the camera utilize.
/// Choices:
/// - Daily Driver: 12000mV
/// - Balanced: 11900mV
/// - Extended: 11800mV
/// - Extreme: 11701mV
@property (nonatomic, assign, readonly) int protectionVoltage;

/// Seconds the camera stays up in parking mode.
@property (nonatomic, assign, readonly) int parkSleepDelay;

@property (nonatomic, assign, readonly) BOOL isAudioPromptEnabled;

@property (nonatomic, strong, nullable) NSDictionary *mountConfig;

@property (nonatomic, assign, readonly) BOOL hasDmsCamera;
@property (nonatomic, strong, readonly, nullable) WLObdWorkModeConfig *obdWorkModeConfig;
@property (nonatomic, strong, readonly, nullable) WLAdasConfig *adasConfig;
@property (nonatomic, strong, readonly, nullable) WLAuxConfig *auxConfig;

@property (nonatomic, assign, readonly) BOOL isVirtualIgnitionEnabled;

- (NSString *)getIP;
- (NSString *)getLivePreviewAddress;
+ (WLProductSerie)determineProductSerieWithHardwareVersion:(nullable NSString *)hardwareVersion NS_SWIFT_NAME(determineProductSerie(with:));

#pragma mark - Camera Control

- (void)reboot;

- (void)startRecord;
- (void)stopRecord;

- (void)updateStorageSpaceInfo;

- (void)setCameraName:(NSString *)name;

- (void)setMicMute:(BOOL)bMute gain:(int)gain;

- (void)setLiveMarkParam:(int)before after:(int)after;
- (void)liveMark;

- (void)formatTFCard;
- (void)factoryReset;

/// Start downloading camera log task.
/// @param progressHandler A block object using to monitor the current download progress.
/// @param destination A block object to be executed in order to determine the destination of the downloaded file. This block returns the desired file URL of the resulting download. If the block is nil, The file will be saved to temporary directory by defaultL.
/// @param completionHandler A block to be executed when the task finishes. This block has no return value and takes three arguments: the finish flag, the path of the downloaded file, and the error occurred during downloading, if any.
//- (void)downloadLogWithProgress:(nullable void (^)(float progress))progressHandler
//                    destination:(nullable NSURL * (^)(void))destination
//              completionHandler:(nullable void (^)(BOOL finished, NSURL * __nullable filePath, NSError * __nullable error))completionHandler;

- (void)downloadLogWithProgress:(nullable void (^)(float progress))progressHandler
                    destination:(nullable NSURL * (^)(void))destination
                           date:(NSString*)date
              completionHandler:(nullable void (^)(BOOL finished, NSURL * __nullable filePath, NSError * __nullable error))completionHandler;
- (void)downloadDebugLogWithProgress:(nullable void (^)(float progress))progressHandler
                    destination:(nullable NSURL * (^)(void))destination
                   completionHandler:(nullable void (^)(BOOL finished, NSURL * __nullable filePath, NSError * __nullable error))completionHandler;
- (void)enterDmsCameraCalibrationMode;
- (void)exitDmsCameraCalibrationMode;
- (void)calibrateWithX:(float)x y:(float)y z:(float)z completionHandler:(nullable WLDmsCameraCalibrateCompletionHandler)completionHandler;

// Live Raw Data
- (void)doRequireLiveDMS:(BOOL)require;
- (void)doRequireLiveRawDataWithACC:(BOOL)acc GPS:(BOOL)gps OBD:(BOOL)obd;

- (void)getCameraServerAddress;
- (void)setCameraServer:(NSString *)address NS_SWIFT_NAME(setCameraServer(address:));
- (void)getPassword;
//- (void)copyLog;
-(void)copyLog:(NSString *)day;
-(void)copyDebugLog;
- (void)setHDRMode:(WLCameraHDRMode)mode;

// api 1.9
- (void)getMountAccelLevels;
- (void)setMountAccelLevel:(NSString *)level;
- (void)getMountAccelParam:(NSString *)level;
- (void)setMountAccelForLevel:(NSString *)level param:(NSString *)param;
- (void)getMarkStorageOptions;
- (void)setMarkStorage:(int)gb;
- (void)getAudioPromptEnabled;
- (void)setAudioPromptEnabled:(BOOL)enabled;
// api 1.9 done

// api 1.10
- (void)getLTEStatus;
- (void)getRadarSensitivity;
- (void)setRadarSensitivity:(int)level;
// api 1.10 done

// api 1.12
- (void)getMountACCTrust;
- (void)setMountACCTrust:(BOOL)trusted;
// api 1.12 done

// api 1.13
- (void)getAppKeepAlive;
- (void)setAppKeepAlive:(BOOL)keep;
- (void)getAttitude;
- (void)setAttitude:(BOOL)upsidedown;
- (void)getSupportUpsideDown;
// api 1.13 done

// api 1.14
- (void)doGetProtectionVoltage;
- (void)doSetProtectionVoltage:(int)voltage;
- (void)doGetParkSleepDelay;
- (void)doSetParkSleepDelay:(int)delaySeconds;
// api 1.14 done

- (void)doGetObdWorkModeConfig;
- (void)doSetObdWorkModeConfig:(WLObdWorkModeConfig *)config;

- (void)getIIOEventDetectionParam;
- (void)setIIOEventDetectionParam:(NSString *)param;

- (void)doGetAdasConfig;
- (void)doSetAdasConfig:(WLAdasConfig *)config;

- (void)doGetAuxConfig;
- (void)doSetAuxConfig:(int)angle;

- (void)doGetVirtualIgnitionConfig;
- (void)doSetVirtualIgnitionConfigWithEnable:(BOOL)enable;

/////////////////////// ↓ Evcam ↓ ///////////////////////

- (void)transferFirmware:(NSData *)firmwareData size:(int)firmwareSize md5:(NSString *)md5 rebootNeeded:(BOOL)rebootNeeded;
- (void)doSetRecordConfig:(NSString *)recordConfig bitrateFactor:(int)bitrateFactor forceCodec:(int)forceCodec;
- (void)doGetRecordConfigList;
- (void)doSetVinMirror:(NSArray *)vinMirrorList;
- (void)doGetVinMirror;

/////////////////////// ↑ Evcam ↑ ///////////////////////
///
/// // for MK
- (void) doGetConfigSettingMK: (NSString *)cmd;
- (void) doSetConfigSettingMK:(NSDictionary *)config cmd:(NSString *)cmd;


@end

NS_ASSUME_NONNULL_END

