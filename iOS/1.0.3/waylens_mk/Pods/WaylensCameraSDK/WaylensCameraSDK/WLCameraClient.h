//
//  CameraClient.h
//  Vidit
//
//  Created by gliu on 15/1/28.
//  Copyright (c)2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDefine.h"
#import "WLSocketClient.h"

@class WLCameraRecordConfig;
@class WLObdWorkModeConfig;
@class WLAdasConfig;
@class WLAuxConfig;

@protocol WLCameraClientDelegate <NSObject>

- (WLCommunicationProtocolVersion)protocolVersion;

- (void)onCameraName:(char*)name;
- (void)onRecordState:(WLRecordState)state;
- (void)onBatteryVolume:(int)mV percentage:(int)percentage
__deprecated_msg("use onBatteryInfo: percentage: instead.");
- (void)onBatteryInfo:(NSDictionary *)info percentage:(int)percentage;
- (void)onGetApiVersion:(const char*)version;
- (void)onRecordingTime:(unsigned int)time;

- (void)onPowerSupplyState:(int)state;
- (void)onStorageState:(WLStorageState)state format:(NSString *)format;
- (void)onStorageSpace:(unsigned long long)all free:(unsigned long long)free;
- (void)onMicEnabled:(BOOL)is volume:(int)volume;

- (void)onSupportedResolutionList:(unsigned long long)result;
- (void)onSupportedQualityList:(unsigned long long)result;
- (void)onSupportedColorModeList:(unsigned long long)result;
- (void)onSupportedRecModeList:(unsigned long long)result;

- (void)onCurrentQuality:(int)index;
- (void)onCurrentResolution:(int)index;
- (void)onCurrentRecMode:(int)index;
- (void)onCurrentColorMode:(int)index;

- (void)onOverlayInfoName:(BOOL)bName time:(BOOL)bTime posi:(BOOL)bPosi speed:(BOOL)bSpeed;
- (void)onRotateMode:(WLCameraRotateMode)mode rotated:(BOOL)rotated;
- (void)onLiveMarkParam:(int)before After:(int)after;

- (void)onGetWiFiMode:(int)mode SSID:(NSString*)ssid;
- (void)onGetWiFiHostNum:(int)num;
- (void)onGetWiFiHostInfor:(NSString*)name;

- (void)onRecErr:(NSError*)err;
- (void)onLiveMark:(BOOL)done;

// for cameraclient only
- (void)onBTisSupported:(BOOL)bSupported;
- (void)onBTisEnabled:(BOOL)bEnabled;
- (void)onGetBTDevType:(eBTType)type Status:(WLBluetoothStatus)status Mac:(NSString*)deviceMac Name:(NSString*)name; //deprecated
- (void)onGetBTDevHostNum:(int)num; //deprecated
- (void)onGetBTDevHostInfor:(NSString*)name Mac:(NSString*)mac; //deprecated
- (void)onBTDev:(eBTType)type BindDone:(int)result;
- (void)onBTDev:(eBTType)type UnBindDone:(int)result;
- (void)onBTInfo:(eBTType)type UnBindDone:(int)result;
// for evcam only
- (void)ongetBTInfoWithSupported:(BOOL)bSupported
                         enabled:(BOOL)bEnabled
                        scanning:(BOOL)isScanning
                       OBDStatus:(NSString*)obdStatus
                         OBDName:(NSString*)obdName
                          OBDMac:(NSString*)obdMac
                       HIDStatus:(NSString*)hidStatus
                         HIDName:(NSString*)hidName
                          HIDMac:(NSString*)hidMac
                       HIDBatLev:(int)hidBatLev;
// for both cameraclient and evcam
- (void)onBTDevScanDone:(int)done withList:(NSDictionary*)list;

- (void)onGetVIN:(NSString*)vin;

- (void)onCurrentDevice:(NSString*)sn FW:(NSString*)vFw hardware:(NSString*)vHw;
- (void)onReadyToUpgrade;
- (void)onUpgradeResult:(int)process;

//CMD 61,76-87 delegate callback methods
- (void)onFormatTFCard:(BOOL)success;

- (void)onSetAutoPowerOffDelay:(BOOL)success;
- (void)onGetAutoPowerOffDelay:(NSString*)delay;

- (void)onSetSpeakerStatus:(BOOL)success;
- (void)onGetSpeakerStatus:(BOOL)mute volume:(int)volume;

- (void)onSetDisplayAutoBrightness:(BOOL)success;
- (void)onGetDisplayAutoBrightness:(BOOL)autoBrightness;

- (void)onSetDisplayBrightness:(BOOL)success;
- (void)onGetDisplayBrightness:(int)brightnessLevel;

- (void)onSetDisplayAutoOffTime:(BOOL)success;
- (void)onGetDisplayAutoOffTime:(NSString*)autoOffTime;

- (void)onFactoryReset:(BOOL)success;

- (void)onGetConnectedClientsCount:(int)count;

- (void)onGetDevieTime:(int)time timeZone:(int)sec;

- (void)onGetMainBitrate:(double)mainBitrate secondBitrate:(double)secondBitrate;

- (void)onGetScreenSaverStyle:(NSString*)style;
- (void)onSetScreenSaverStyle:(BOOL)success;

- (void)onGetAchtServer:(BOOL)bTest;
- (void)onCopyLog:(BOOL)success;
- (void)onCopyDebugLog:(BOOL)success;
- (void)onGet360Server:(NSString *)address;
- (void)onSet360Server:(BOOL)success;
- (void)onGetKey:(NSString *)key;
- (void)onGetMountConfig:(NSDictionary *)dict;
- (void)onSetMountConfig:(BOOL)success;
- (void)onGetMountVersion:(NSDictionary *)dict;
- (void)onGetMonitorMode:(NSString *)mode;
- (void)onSetHDRMode:(BOOL)success;
- (void)onGetHDRMode:(WLCameraHDRMode)mode;

// api 1.9
- (void)onGetMountAccelLevels:(NSArray*)levels current:(NSString*)current;
- (void)onSetMountAccelLevel:(BOOL)result;
- (void)onGetAudioPromptEnabled:(BOOL)enabled;
- (void)onSetAudioPromptEnabled:(BOOL)success;
- (void)onGetICCID: (NSString *)iccid;
- (void)onGetLTEFirmwareVersionPublic: (NSString *)publicVersion internal:(NSString*)internalVersion;
- (void)onGetLTEStatus: (NSDictionary *)status;
// for debug
- (void)onGetMountAccelParam:(NSString*)param;
- (void)onSetMountAccelParam:(BOOL)result;

//- (void)onSyncTimeEx:(long)timeSince1970 Zone:(int)zoneInSec DaylightSaving:(BOOL)bSaving;
- (void)onGetTimeZone:(int)zoneInSec DaylightSaving:(BOOL)bSaving;

- (void)onGetMarkStorageOptions:(NSArray*)levels current:(int)currentInGB;
- (void)onSetMarkStorage:(int)gb;
// api 1.9 end

// api 1.10
- (void)onGetRadarSensitivity:(float)level;
- (void)onSetRadarSensitivity:(float)level;
- (void)onDebugProp:(NSString*)prop value:(NSString*)value;
// api 1.10 done

// api 1.12
- (void)onGetMountACCTrust:(BOOL)trusted;
// api 1.12 done

// api 1.13
- (void)onGetAppKeepAlive:(BOOL)keep;
- (void)onGetAttitude:(BOOL)isUpsideDown;
- (void)onGetSupportUpsideDown:(BOOL)isSupported;
// api 1.13 done

// api 1.14
- (void)onGetSupportRiskDriveEvent:(BOOL)supported;
- (void)onGetAPN:(NSString *)apn;
- (void)onGetSupportWlanMode:(BOOL)supported;
- (void)onGetProtectionVoltage:(int)voltage;
- (void)onGetParkSleepDelay:(int)delaySeconds;
- (void)onGetSubStreamOnly:(BOOL)isOnly;
- (void)onGetMainQuality:(int)mainQuality subQuality:(int)subQuality;
- (void)onSetQuality:(BOOL)success;
// api 1.14 done

- (void)onGetObdWorkModeConfig:(WLObdWorkModeConfig *)obdWorkModeConfig;
- (void)onGetAdasConfig:(WLAdasConfig *)adasConfig;
- (void)onGetVirtualIgnitionConfigWithEnable:(BOOL)enable;
- (void)onGetAuxConfig:(WLAuxConfig *)auxConfig;

//debug
- (void)onGetIIOEventDetectionParam:(NSString*)param;
- (void)onSetIIOEventDetectionParam:(BOOL)result;

//Evcam
- (void)onTransferFirmware:(int)state size:(int)firmwareSize progress:(int)progress errorCode:(int)errorCode;
- (void)onGetRecordConfigList:(NSArray *)recordConfigList;
- (void)onGetRecordConfig:(WLCameraRecordConfig *)cameraRecordConfig;
- (void)onGetVinMirror:(NSArray *)vinMirrorList;

// for TW03
- (void)onSetHotspotInfoWithSsid:(NSString *)ssid andPassword:(NSString *)password;

//MK
- (void)onGetConfigSettingMK:(NSDictionary *)mkConfig cmd:(NSString*)cmd;



@end

@interface WLCameraClient: WLSocketClient

@property (weak, nonatomic) id<WLCameraClientDelegate> cameraClientDelegate;

- (void)getCameraState;
- (void)startRecord;
- (void)stopRecord;
- (void)getAllInfor;
- (void)getStorageInfos;
- (void)getRecordTime;
- (void)getCameraName;
- (void)setCameraName:(NSString*)name;
- (void)setPreviewStreamSize:(BOOL)bBig;

- (void)getResolutionList;
- (void)getCurrentResolution;
- (void)setResolution:(eVideoResolution)resolution;

- (void)getQualityList;
- (void)getCurrentQuality;
- (void)setQuality:(WLVideoQuality)quality;
- (void)setMainQuality:(WLVideoQuality)mainQuality subQuality:(WLVideoQuality)subQuality;

- (void)getRecModeList;
- (void)getCurrentRecMode;
- (void)setRecMode:(WLRecordMode)mode;

- (void)getColorModeList;
- (void)getCurrentColorMode;
- (void)setColorMode:(eColorMode)mode;

- (void)powerOff;
- (void)reboot;

- (void)getWlanMode;
- (void)getHostNumber;
- (void)getHostInfor:(int)index;
- (void)addHost:(NSString*)ssid password:(NSString*)pwd;
- (void)removeHost:(NSString*)ssid;
- (void)connectHost:(NSString*)ssid mode:(int)mode;

- (void)syncTime:(long)timeSince1970 zone:(int)zoneInSec;
- (void)getDevicetime;

- (void)getMicState;
- (void)setMic:(BOOL)bMute gain:(int)gain;

- (void)getOverlayState;
- (void)setOverlayWithName:(BOOL)bname time:(BOOL)btime gps:(BOOL)bgps speed:(BOOL)bspeed;

- (void)getRotateParam;
- (void)setRotateParam:(BOOL)HFlip andVertical:(BOOL)VFlip;

// > 1.5.05
- (void)setRotateMode:(WLCameraRotateMode)mode;


- (void)getLiveMarkParam;
- (void)setLiveMarkParam:(int)before after:(int)after;
- (void)doLiveMark;

- (void)getFWVersion;
- (void)newFirmwareVersion:(NSString*)md5 withURL:(NSString*)url;
- (void)doUpgradeFirmware;

- (void)doScanWiFiHost;
- (void)doConnectToSSID:(NSString*)ssid;

- (void)getAPIVersion;
- (void)isAPISupported:(int)api inDomain:(int)domain;

- (void)getBTSupported;
- (void)getBTOpened;
- (void)doBTOpen:(BOOL)open;
- (void)updateOBDStatus;
- (void)updateHIDStatus;
- (void)updateVin;
- (void)doBTScan;
- (void)updateBTHostNum; //deprecated
- (void)updateBTHostInfor:(int)index; //deprecated
- (void)doOBDBind:(NSString*)mac;
- (void)doHIDBind:(NSString*)mac;
- (void)doOBDUnBind;
- (void)doHIDUnBind;

//CMD 61,76-87
- (void)formatTFCard;

- (void)setAutoPowerOffDelay:(NSString*)delay;
- (void)getAutoPowerOffDelay;

- (void)setSpeakerStatus:(BOOL)enabled volume:(int)volume;
- (void)onGetSpeakerStatus;

- (void)setDisplayAutoBrightness:(BOOL)autoBrightness;
- (void)getDisplayAutoBrightness;

- (void)setDisplayBrightness:(int)brightnessLevel;
- (void)getDisplayBrightness;

- (void)setDisplayAutoOffTime:(NSString*)autoOffTime;
- (void)getDisplayAutoOffTime;

- (void)factoryReset;

- (void)getConnectedClientsCount;

- (void)getScreenSaverStyle;
- (void)setScreenSaverStyle:(NSString*)style;

- (void)getKey;
- (void)get360Server;
- (void)set360Server:(NSString *)address;
-(void)copyLog:(NSString *)day;
-(void)copyDebugLog;
- (void)getMountConfig;
- (void)setMountConfig:(NSDictionary *)dict;
- (void)getMonitorMode;
- (void)getMountVersion;
- (void)getHDRMode;
- (void)setHDRMode:(WLCameraHDRMode)mode;

// api 1.9
- (void)getMountAccelLevels;
- (void)setMountAccelLevel:(NSString*)level;
- (void)getMountAccelParam:(NSString*)level;
- (void)setMountAccelForLevel:(NSString*)level Param:(NSString*)param;

- (void)syncTimeEx:(long)timeSince1970 Zone:(int)zoneInSec DaylightSaving:(BOOL)bSaving;
- (void)getTimeZone;

- (void)getMarkStorageOptions;
- (void)setMarkStorage:(int)gb;
- (void)getAudioPromptEnabled;
- (void)setAudioPromptEnabled:(BOOL)enabled;
// api 1.9 done

// api 1.10
- (void)getICCID;
- (void)getLTEFirmwareVersion;
- (void)getLTEStatus;
- (void)getRadarSensitivity;
- (void)setRadarSensitivity:(int)level;
- (void)doDebugProps:(BOOL)setOrGet prop:(NSString*)prop action:(NSString*)action value:(NSString*)value key:(NSString*)key;
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
- (void)getSupportRiskDriveEvent;
- (void)setSupportRiskDriveEvent:(BOOL)supported;
- (void)getAPN;
- (void)setAPN:(NSString *)apn;
- (void)getSupportWlanMode;
- (void)getProtectionVoltage;
- (void)setProtectionVoltage:(int)voltage;
- (void)getParkSleepDelay;
- (void)setParkSleepDelay:(int)delaySeconds;
- (void)getSubStreamOnly;
- (void)setSubStreamOnly:(BOOL)isOnly;
// api 1.14 done

- (void)getIIOEventDetectionParam;
- (void)setIIOEventDetectionParam:(NSString *)param;

- (void)getObdWorkModeConfig;
- (void)setObdWorkModeConfig:(WLObdWorkModeConfig *)config;

- (void)getAdasModeConfig;
- (void)setAdasConfig:(WLAdasConfig *)config;

- (void)getVirtualIgnitionConfig;
- (void)setVirtualIgnitionConfigWithEnable:(BOOL)enable;

- (void)getAuxConfig;
- (void)setAuxConfig:(int)angle;

/////////////////////// ↓ Evcam ↓ ///////////////////////

- (void)transferFirmware:(NSData *)firmwareData size:(int)firmwareSize md5:(NSString *)md5 rebootNeeded:(BOOL)rebootNeeded;
- (void)getUserFileList;
- (void)setRecordConfig:(NSString *)recordConfig bitrateFactor:(int)bitrateFactor forceCodec:(int)forceCodec;
- (void)getRecordConfigList;
- (void)getRecordConfig;
- (void)setVinMirror:(NSArray *)vinMirrorList;
- (void)getVinMirror;

/////////////////////// ↑ Evcam ↑ ///////////////////////
///
///// MK
- (void)setConfigSettingMK:(NSDictionary *)config cmd:(NSString *)cmd;
- (void)getConfigSettingMK:(NSString *)cmd;


@end
