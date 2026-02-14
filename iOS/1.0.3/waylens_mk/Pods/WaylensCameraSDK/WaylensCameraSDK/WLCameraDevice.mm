//
//  WLCameraDevice.m
//  Vidit
//
//  Created by gliu on 15/1/7.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import "WLCameraDevice.h"
#import <netinet/in.h>
#import <arpa/inet.h>

#import <WaylensFoundation/WaylensFoundation.h>

#import "WLDmsClient.h"
#import "WLCameraClient.h"
#import "WLCameraDevice+FrameworkInternal.h"
#import "CDevice+FrameworkInternal.h"
#import "WLCameraVDBClient+FrameworkInternal.h"
#import "WLCameraVDBClipsAgent+FrameworkInternal.h"
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>
#import "vdb_cmd.h"
#import "Define+FrameworkInternal.h"
#import "WLCameraSettingsListItem.h"
#import "WLCameraLogDownloader.h"

@interface WLCameraDevice() <WLSocketClientConnectionDelegate, WLCameraClientDelegate, WLCameraSpaceDelegate, WLCameraLogDownloaderDelegate> {
    BOOL bCameraClientConnected;
    BOOL bVDBClientConnected;
    NSArray*   allResolutionList;
    NSArray*   allQualityList;
    NSArray*   allRecordModeList;
    NSArray*   allColorModeList;

    NSMutableArray* observerList;
}
@property (strong, nonatomic) WLCameraClient*     cameraClient;
@property (strong, nonatomic) WLCameraVDBClient*  vdbClient;
@property (strong, nonatomic) WLCameraVDBClipsAgent*  clipsAgent;
@property (strong, nonatomic) WLDmsClient* dmsClent;
@property (assign, nonatomic) BOOL isReady;
@property (assign, nonatomic) NSTimeInterval lastDeactiveTime;
@property (assign, nonatomic) BOOL isMountACCTrusted;

@property (assign, nonatomic) BOOL keepAliveIfAppConnected;
@property (assign, nonatomic) BOOL isUpsideDown;
@property (strong, nonatomic) NSNumber *isSupportUpsideDown;
@property (strong, nonatomic) NSString *apn;
@property (assign, nonatomic) BOOL isSupportWlanMode;
@property (assign, nonatomic) BOOL isSupportRiskDriveEvent;
@property (assign, nonatomic) BOOL isSubStreamOnly;
@property (assign, nonatomic) int protectionVoltage;
@property (assign, nonatomic) int parkSleepDelay;

@property (strong, nonatomic) NSString* apiVersion;

@property (nonatomic, strong) NSArray* vinMirrorList;
@property (nonatomic, strong) NSArray* recordConfigList;
@property (nonatomic, strong) WLCameraRecordConfig* recordConfig;

@property (nonatomic, assign) BOOL hasDmsCamera;

@property (nonatomic, strong) NSArray* resolutionList;
@property (nonatomic, strong) NSArray* colorModeList;
@property (nonatomic, strong) NSArray* recordModeList;
@property (nonatomic, strong) NSArray *qualityList;

// Firmware
@property (nonatomic, assign) BOOL popFWUpgradeAlert;

@property (nonatomic, strong) NSString *defaultSSID;
@property (nonatomic, assign) BOOL isNeedUpgrade;
@property (nonatomic, strong) NSString *latestApiVersion;
@property (nonatomic, assign) int majVersion;
@property (nonatomic, assign) int minVersion;
@property (nonatomic, assign) int buildVersion;
@property (nonatomic, strong) NSString *latestBspVersion;
@property (nonatomic, strong) NSDictionary *upgradeDescription;

////connection

@property (nonatomic, assign) WLWiFiMode wifiMode;      //0:AP, 1:Client, 2: Off
@property (nonatomic, strong) NSMutableArray *wifiHostList;
@property (nonatomic, assign) NSUInteger wifiHostNum;
@property (nonatomic, assign) BOOL isSupportBluetooth;
// read properties blow after BT State changed
@property (nonatomic, strong) NSString *obdBindDeviceMac;
@property (nonatomic, strong) NSString *obdBindDeviceName;
@property (nonatomic, strong) NSString *hidBindDeviceMac;
@property (nonatomic, strong) NSString *hidBindDeviceName;
@property (nonatomic, strong) NSMutableArray *obdHostList;
@property (nonatomic, strong) NSMutableArray *hidHostList;
@property (nonatomic, strong) NSMutableArray *otherBluetoothList;
@property (nonatomic, assign) NSUInteger bluetoothHostNum;


// Overlay
@property (nonatomic, assign) BOOL    isShowOverlayName;
@property (nonatomic, assign) BOOL    isShowOverlayTime;
@property (nonatomic, assign) BOOL    isShowOverlayGPS;
@property (nonatomic, assign) BOOL    isShowOverlaySpeed;

@property (strong, nonatomic) NSString *screenSaverStyle;

@property (nonatomic, strong) NSString *autoPowerOffDelay; //support : "Never", "30s", "60s", "2min", "5min"

@property (nonatomic, assign) BOOL displayAutoBrightness;
@property (nonatomic, assign) int displayBrightness;
@property (nonatomic, strong) NSString *displayAutoOffTime; //@see autoPowerOffDelay

@property (nonatomic, assign) int speakerVolume;
@property (nonatomic, assign) BOOL speakerEnabled;

@property (nonatomic, assign) int connectedClientCount;
@property (nonatomic, assign) BOOL isConnect2TestAchtServer;
@property (nonatomic, strong) NSString *vehicleIdentifyNum;

@property (nonatomic, assign) eVideoResolution resolution;
@property (nonatomic, assign) eColorMode colorMode;

@property (nonatomic, weak) id<WLCameraDeviceDelegate> delegate;

@property (nonatomic, assign) WLCameraRotateMode rotationMode;

@property (nonatomic, assign) BOOL isOverlayConfigChanged;
@property (nonatomic, assign) BOOL isLiveMarkTimeChanged;

@property (nonatomic, assign) WLRecordMode recMode;
@property (assign, nonatomic, getter=isCamera) BOOL isCamera;

@property (nonatomic, assign) WLRecordState recState;      //stop, recing, stopping, starting

@property (nonatomic, strong) NSString *accelerometerLevel;

@property (nonatomic, assign) int totalMB;
@property (nonatomic, assign) int freeMB;
@property (nonatomic, assign) int clipMB;
@property (nonatomic, assign) int markedMB;      //cannot be erased automatically, -1 means unknown
@property (nonatomic, assign) WLStorageState storageState;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, assign) int batteryState;
@property (nonatomic, assign) BOOL isCharging;

@property (nonatomic, assign) BOOL isMute; //MIC
@property (nonatomic, assign) int micLevel;

@property (nonatomic, assign) int bluetoothScanState;   //0. idle; 1. ing; 2. done; 3. getListDone; -1: failed; -2: need reboot
@property (nonatomic, assign) WLBluetoothStatus obdConnectState;
@property (nonatomic, assign) WLBluetoothStatus hidConnectState;
@property (nonatomic, assign) BOOL isBluetoothOpen;

@property (nonatomic, assign) double mainBitrate;
@property (nonatomic, assign) double secondBitrate;

@property (nonatomic, assign) WLVideoQuality quality;
@property (nonatomic, assign) WLVideoQuality subQuality;

@property (nonatomic, assign) BOOL isAudioPromptEnabled;

@property (nonatomic, strong, nullable) WLBatteryInfo *batteryInfo;
    
@property (nonatomic, strong) WLObdWorkModeConfig *obdWorkModeConfig;
@property (nonatomic, strong, nullable) WLAdasConfig *adasConfig;
@property (nonatomic, strong, nullable) WLAuxConfig *auxConfig;

@property (nonatomic, assign) BOOL isVirtualIgnitionEnabled;

// Log
@property (nonatomic, strong, nullable) WLCameraLogDownloader *logDownloader;
@property (nonatomic, copy, nullable) void (^logProgressHandler)(float progress);
@property (nonatomic, copy, nullable) NSURL *(^logDestination)(void);
@property (nonatomic, copy, nullable) void (^logCompletionHandler)(BOOL finished, NSURL * __nullable filePath, NSError * __nullable error);

- (NSString *)getLiveRTSPAddress;

- (void)addObserver:(__weak id)observer forKeys:(NSArray *)keys;
- (void)removeObserver:(id)observer;

- (void)powerOff;

- (void)updateAllBasicInfo;

- (void)isAPISupported:(int)idx inDomain:(int)domain;
- (void)updateRecordTimeInfo;

- (void)updateWifiMode;
- (void)scanWiFiHost;

- (void)syncTime:(long)time zone:(int)timezone;
- (void)synchronizeDateTime;
- (void)syncTimeEx:(long)timeSince1970 zone:(int)zoneInSec daylightSaving:(BOOL)bSaving;
- (void)getTimeZone;

- (void)updateOBDStatus;
- (void)updateHIDStatus;
- (void)updateBluetoothHostNum;
- (void)updateBluetoothHostInfo:(int)index;

- (NSString *)getUpgradeDescription;

+ (NSArray *)supportedAutoPowerOffDelay;
+ (NSArray *)supportedDisplayAutoOffTime;

- (void)doSetAutoPowerOffDelay:(NSString*)delay;
- (void)doGetAutoPowerOffDelay;

- (void)doSetSpeakerStatus:(BOOL)enabled volume:(int)volume;
- (void)doGetSpeakerStatus;

- (void)doSetDisplayAutoBrightness:(BOOL)autoBrightness;
- (void)doGetDisplayAutoBrightness;

- (void)doSetDisplayBrightness:(int)brightnessLevel;
- (void)doGetDisplayBrightness;

- (void)doSetDisplayAutoOffTime:(NSString*)autoOffTime;
- (void)doGetDisplayAutoOffTime;

- (void)doGetConnectedClientsCount;

- (void)doGetBitrate;

- (void)doGetScreenSaverStyle;
- (void)doSetScrrenSaverStyle:(NSString*)style;

- (void)onRotateMode:(WLCameraRotateMode)mode rotated:(BOOL)rotated;
- (void)setOverlayName:(BOOL)bNameOn time:(BOOL)bTimeOn posi:(BOOL)bGPSOn speed:(BOOL)bSpeed;

- (void)getStorageInfos;

@end

@implementation WLCameraDevice

- (instancetype)initWithIPv4:(NSString*)ipv4 IPv6:(NSString*)ipv6 port:(long)port
          isCamera:(BOOL)isCamera {

    self = [super initWithIPv4:ipv4 IPv6:ipv6 port:port];
    if(self) {
        _isCamera = isCamera;
        _wifiMode = Wifi_Mode_Client;
        if ([WaylensCameraSDKConfig.current.defaultIPV4sUsingInCamera containsObject:_ipv4]) {
            _wifiMode = Wifi_Mode_AP;
        }
        _delegate = nil;
        bCameraClientConnected = NO;
        bVDBClientConnected = NO;
        _vehicleIdentifyNum = nil;
        _isUpsideDown = NO;
        _hasDmsCamera = NO;
        if (isCamera) {
            _cameraClient = [[WLCameraClient alloc] initWithIPv4:_ipv4 IPv6:_ipv6 port:(long)_port];
            [_cameraClient setConnectionDelegate:self];
            [_cameraClient setCameraClientDelegate:self];
            observerList = [[NSMutableArray alloc] init];
        } else {
            _cameraClient = nil;
        }
        [self initProperties];
    }
    return self;
}
- (void)dealloc {
    NSArray* observers = [observerList mutableArrayValueForKey:@"Observer"];
    for (id ob in observers) {
        [self removeObserver:ob];
    }
}
- (void)initSupportedFeature {
    allResolutionList   = [NSArray arrayWithObjects:@"1080p30", @"1080p60", @"720p30", @"720p60", @"4Kp30", @"4Kp60", @"480p30", @"480p60", @"720p120", @"Still", @"QXVGAp30", @"360", @"PhotoMode", nil];
    allQualityList      = [NSArray arrayWithObjects:@"Super High", @"High", @"Normal", @"Low", @"Super Low", @"Normal 5FPS", @"Low 5FPS", @"Super Low 5FPS", nil];
    allRecordModeList   = [NSArray arrayWithObjects:@"All manual", @"Power on Rec", @"Circle", @"Power on Rec and Circle", nil];
    allColorModeList    = [NSArray arrayWithObjects:@"Normal", @"Sport", @"Drive", @"Scene", nil];

    _resolutionList = nil;
    _qualityList    = nil;
    _recordModeList = nil;
    _colorModeList  = nil;
    _vinMirrorList  = nil;
    _recordModeList = nil;
    _recordConfig   = nil;
}

- (void)initProperties {
    _name = nil;
    [self initSupportedFeature];

    _apiVersion = nil;
    _sn         = nil;
    _firmwareVersion  = nil;
    _hardwareModel    = nil;
    _defaultSSID    = nil;
    _isNeedUpgrade   = NO;
    _popFWUpgradeAlert = NO;
    _upgradeDescription = nil;

    _wifiHostList   = [[NSMutableArray alloc]init];
    _isSupportBluetooth   = YES;
    _obdConnectState   = BTStatus_OFF;
    _hidConnectState   = BTStatus_OFF;
    _obdBindDeviceMac  = nil;
    _obdBindDeviceName = nil;
    _hidBindDeviceMac  = nil;
    _obdBindDeviceName = nil;
    _obdHostList     = [[NSMutableArray alloc]init];
    _hidHostList     = [[NSMutableArray alloc]init];
    _otherBluetoothList = [[NSMutableArray alloc]init];

    _resolution                = Video_Resolution_num;
    _quality                   = Video_Quality_num;
    _subQuality                = Video_Quality_num;
    _recMode                   = Rec_Mode_num;
    _colorMode                 = Color_Mode_num;
    _recState                  = WLRecordStateNum;
    _storageState              = WLStorageStateNum;
//    _cameraMode                = -1;
    _freeMB                    = 0;
    _clipMB                    = 0;
    _markedMB                  = -1;
    _batteryState              = 50;
    _isCharging                = NO;
    _isMute                    = NO;
    _bluetoothScanState        = 0;
    _isBluetoothOpen           = NO;
    _isOverlayConfigChanged    = NO;

    _isConnect2TestAchtServer  = YES;

    _isSupportUpsideDown      = nil;
    _apn                      = @"";
    _isSupportWlanMode        = NO;
    _isSupportRiskDriveEvent  = NO;
    _isSubStreamOnly          = NO;
    _protectionVoltage        = 0;
    _parkSleepDelay           = 0;
    _isVirtualIgnitionEnabled = NO;
}

-(BOOL)isConnected{
    return bCameraClientConnected && bVDBClientConnected;
}

- (BOOL)isReady {
    return self.isConnected && _sn.length && _name.length;
}

- (void)connect {
    if (_isCamera) {
        bCameraClientConnected = NO;
        [_cameraClient connect];
    } else {
        bCameraClientConnected = YES;
    }

    if (_vdbClient == Nil) {
        _vdbClient = [[WLCameraVDBClient alloc] initWithIPv4:_ipv4 IPv6:_ipv6 port:VDB_CMD_PORT];
        [_vdbClient setConnectionDelegate:self];
        _clipsAgent = [[WLCameraVDBClipsAgent alloc] initWithVDB:_vdbClient];
        _vdbClient.clipsDelegate = _clipsAgent;
    }
    bVDBClientConnected = NO;
    [_vdbClient connect];

    if (_dmsClent == nil) {
        _dmsClent = [[WLDmsClient alloc] initWithIPv4:_ipv4 IPv6:nil port:1368];
        [_dmsClent setConnectionDelegate:self];
    }
    [_dmsClent connect];

    if (bCameraClientConnected == NO || bVDBClientConnected == NO) {
//        [_delegate onDeviceDisconnected:self];
    }
}

- (void)disconnect {
    NSLog(@"camera device disconnect");
    [_clipsAgent onVDBState:NO];

    if (_vdbClient) {
        [_vdbClient setConnectionDelegate:nil];
        [_vdbClient disconnect];
        _vdbClient = nil;
    }

    if (_dmsClent) {
        [_dmsClent setConnectionDelegate:nil];
        [_dmsClent disconnect];
        _dmsClent = nil;
    }

    if (_isCamera && _cameraClient) {
        [_cameraClient setCameraClientDelegate:nil];
        [_cameraClient disconnect];
        _cameraClient = nil;
    }
    bCameraClientConnected = NO;
    bVDBClientConnected = NO;
}

- (void)becomeActive {
    _vdbClient.enableReadTimeout = YES;
    _cameraClient.enableReadTimeout = YES;
    [self getSN];
    
    if ((self.lastDeactiveTime > 0) && ([NSDate date].timeIntervalSince1970 - self.lastDeactiveTime > 600)) {
        [_clipsAgent onVDBState:NO];
    } else {
        [_clipsAgent onVDBState:self.isReady];
    }
    self.lastDeactiveTime = 0;
}

- (void)resignActive {
    _vdbClient.enableReadTimeout = NO;
    _cameraClient.enableReadTimeout = NO;
    self.lastDeactiveTime = [NSDate date].timeIntervalSince1970;
}

- (void)addObserver:(__weak id)observer forKeys:(NSArray*)keys {
    [observerList addObject:[NSDictionary dictionaryWithObjects:@[observer, keys]
                                                        forKeys:@[@"Observer", @"Keys"]]];
    for (NSString* key in keys) {
        [self addObserver:observer forKeyPath:key options:NSKeyValueObservingOptionNew context:nil];
    }
}
- (void)removeObserver:(id)observer {
    NSDictionary* pDict = nil;
    for (NSDictionary* dict in observerList) {
        if ([dict[@"Observer"] isEqual:observer]) {
            pDict = dict;
            break;
        }
    }
    for (NSString* key in pDict[@"Keys"]) {
        [self removeObserver:observer forKeyPath:key context:nil];
    }
    [observerList removeObject:pDict];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    BOOL automatic = NO;
    if ([theKey isEqualToString:@"quality"]) {
        automatic = NO;
    } else {
        automatic = [super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

+ (WLProductSerie)determineProductSerieWithHardwareVersion:(nullable NSString *)hardwareVersion {
    WLProductSerie productSerie = WLProductSerieUnknown;

    if (WaylensCameraSDKConfig.current.target == WaylensCameraSDKTargetToB) {
        BOOL access2CCamera = NO;

        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"access2CCamera.debugoption.acht"];
        if (obj != nil) {
            access2CCamera = [obj boolValue];
        }

        if ([hardwareVersion hasPrefix:@"HORN"]) {
            productSerie = WLProductSerieHorn;
        } else if ([hardwareVersion hasPrefix:@"SC_V2"]) {
            productSerie = WLProductSerieHorn;
        } else if (!access2CCamera && [hardwareVersion hasPrefix:@"SC_V1"]) {
            productSerie = WLProductSerieHorn;
        } else if (access2CCamera && [hardwareVersion hasPrefix:@"SC_"]) {
            productSerie = WLProductSerieHorn;
        } else if (([hardwareVersion hasPrefix:@"SAXHORN_"]) || ([hardwareVersion hasPrefix:@"SH_"])) {
            productSerie = WLProductSerieSaxhorn;
        } else if (([hardwareVersion hasPrefix:@"LONGHORN_"]) || ([hardwareVersion hasPrefix:@"LH_"])) {
            productSerie = WLProductSerieSaxhorn;
        } else if ([hardwareVersion containsString:@"HACHI"]) {
            productSerie = WLProductSerieHachi;
        } else if ([hardwareVersion hasPrefix:@"TW03_"]) {
            productSerie = WLProductSerieSecureES;
        } else {
            productSerie = WLProductSerieUnknown;
        }
    }
    else {
        BOOL access2BCamera = NO;

        id obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"access2BCamera.debugoption.acht"];
        if (obj != nil) {
            access2BCamera = [obj boolValue];
        }

        if ([hardwareVersion hasPrefix:@"HORN"]) {
            productSerie = WLProductSerieHorn;
        } else if (!access2BCamera && [hardwareVersion hasPrefix:@"SC_V0"]) {
            productSerie = WLProductSerieHorn;
        } else if (access2BCamera && [hardwareVersion hasPrefix:@"SC_"]) {
            productSerie = WLProductSerieHorn;
        } else if (([hardwareVersion hasPrefix:@"SAXHORN_"]) || ([hardwareVersion hasPrefix:@"SH_"])) {
            productSerie = WLProductSerieSaxhorn;
        } else if (([hardwareVersion hasPrefix:@"LONGHORN_"]) || ([hardwareVersion hasPrefix:@"LH_"])) {
            productSerie = WLProductSerieSaxhorn;
        } else if ([hardwareVersion containsString:@"HACHI"]) {
            productSerie = WLProductSerieHachi;
        } else if ([hardwareVersion hasPrefix:@"TW03_"]) {
            productSerie = WLProductSerieSecureES;
        } else {
            productSerie = WLProductSerieUnknown;
        }
    }

    return productSerie;
}

- (NSString*)getIP {
    return [_vdbClient getIP];
}
- (NSString*)getLivePreviewAddress {
    return [_vdbClient getLivePreviewAddress];
}
- (NSString*)getLiveRTSPAddress {
    //todo: FIXME
//    return [NSString stringWithFormat:@"rtsp://%@", _address];
    return @"";
}

- (WLCommunicationProtocolVersion)communicationProtocolVersion {
    if ([self.getServiceType isEqualToString:kWaylensServiceTypeEvcam]) {
        return CommunicationProtocolVersionEvcam;
    }
    else if ([self.getServiceType isEqualToString:kWaylensServiceTypeCamClient]) {
        return CommunicationProtocolVersionCamClient;
    }
    else {
        return CommunicationProtocolVersionUnknown;
    }
}

- (void)setNeedUpgrade:(BOOL)need withAPIVersion:(NSString*)apiVersion andBSPVersion:(NSString*)bspVersion andDescription:(NSDictionary*)description {
    if (_isNeedUpgrade != need) {
        _isNeedUpgrade = need;
        _popFWUpgradeAlert = _isNeedUpgrade;
    }
    _latestApiVersion = apiVersion;
    _latestBspVersion = bspVersion;
    _upgradeDescription = [NSDictionary dictionaryWithDictionary:description];
}

// control cmd
- (void)startRecord {
    [_cameraClient startRecord];
}

- (void)stopRecord {
    [_cameraClient stopRecord];
}

- (void)powerOff {
    [_cameraClient powerOff];
}

- (void)reboot {
    [_cameraClient reboot];
}

- (void)enterDmsCameraCalibrationMode {
    [self stopRecord];
}

- (void)exitDmsCameraCalibrationMode {
    [self startRecord];
}

- (void)calibrateWithX:(float)x y:(float)y z:(float)z completionHandler:(nullable WLDmsCameraCalibrateCompletionHandler)completionHandler {
    if ([self.dmsClent isConnected]) {
        [self.dmsClent calibrateWithX:x y:y z:z completionHandler:completionHandler];
    }
    else {
        completionHandler(NO);
    }
}

//
- (void)updateAllBasicInfo {
    [_cameraClient getAllInfor];
    if (self.isBluetoothOpen) {
        [self updateOBDStatus];
        [self updateHIDStatus];
    }
    [_cameraClient getMountAccelLevels];
}
- (void)updateStorageSpaceInfo {
    [_cameraClient getStorageInfos];
    if ([_vdbClient updateSpaceInfo] == NO) {
        [_cameraClient getAllInfor];
    }
}
- (void)getStorageInfos {
    [_cameraClient getStorageInfos];
}
-(void)getSN {
    [_cameraClient getFWVersion];
}

- (void)updateAllInfor {
    [_cameraClient getFWVersion];
    [_cameraClient getAPIVersion];
    [_cameraClient getCameraName];
    [_cameraClient getSupportUpsideDown];
    [_cameraClient getAttitude];
    if ((self.productSerie == WLProductSerieHorn) ||
        (self.productSerie == WLProductSerieSaxhorn)
        ) {
        [_cameraClient getMountConfig];
        [_cameraClient getMonitorMode];
        [_cameraClient getMountVersion];
        [_cameraClient getHDRMode];
        [_cameraClient get360Server];
        [_cameraClient getLTEFirmwareVersion];
        [_cameraClient getICCID];
        [self getPassword];

        if (self.productSerie == WLProductSerieSaxhorn) {
            [_cameraClient getVinMirror];
            [_cameraClient getRecordConfigList];
            [_cameraClient getRecordConfig];
        }
    }
    [self updateAllBasicInfo];
////    [_cameraClient getBTSupported];
    [_cameraClient getBTOpened];
//    [_cameraClient GetCameraMode];
    [_cameraClient getCurrentRecMode];
    [_cameraClient getCameraState];

    if (WaylensCameraSDKConfig.current.target == WaylensCameraSDKTargetToC) {
        [_cameraClient getDevicetime];
    }

    [_cameraClient getAppKeepAlive];
    [_cameraClient getObdWorkModeConfig];
}
- (void)goonGetAllInfor {
    [_cameraClient getResolutionList];
    [_cameraClient getRecModeList];
    [_cameraClient getQualityList];
    [_cameraClient getColorModeList];
    [_cameraClient getCurrentResolution];
    [_cameraClient getCurrentColorMode];
    [_cameraClient getCurrentQuality];
    [_cameraClient getRotateParam];
    [_cameraClient getLiveMarkParam];
    [_cameraClient getMicState];
    [_cameraClient getOverlayState];
    [_cameraClient getAPN];
    [_cameraClient getSupportWlanMode];
    [_cameraClient getSupportRiskDriveEvent];
    [_cameraClient getProtectionVoltage];
    [_cameraClient getParkSleepDelay];
    [_cameraClient getWlanMode];
    [_cameraClient getHostNumber];
    [_cameraClient getSubStreamOnly];
    [_cameraClient getMountACCTrust];
    [_cameraClient getAdasModeConfig];
    [_cameraClient getAuxConfig];
    [_cameraClient getVirtualIgnitionConfig];
}

- (void)setCameraName:(NSString*)name {
    _name = name;
    [_cameraClient setCameraName:name];
    [_cameraClient getCameraName];
}
- (void)isAPISupported:(int)idx inDomain:(int)domain {
    [_cameraClient isAPISupported:idx inDomain:domain];
}
- (void)updateRecordTimeInfo {
    [_cameraClient getRecordTime];
}
- (void)setStream:(BOOL)bBigStream {
    [_cameraClient setPreviewStreamSize:bBigStream];
}
- (void)setResolution:(eVideoResolution)index {
    [_cameraClient setResolution:index];
    [_cameraClient getCurrentResolution];
}

- (void)setQuality:(WLVideoQuality)index {
//    [_cameraClient SetQuality:index];
    [_cameraClient setMainQuality:index subQuality:_subQuality];
}

- (void)setSubQuality:(WLVideoQuality)index {
    [_cameraClient setMainQuality:_quality subQuality:index];
}

- (void)setRecMode:(WLRecordMode)index {
    [_cameraClient setRecMode:index];
    [_cameraClient getCurrentRecMode];
}
- (void)setColorMode:(eColorMode)index {
    [_cameraClient setColorMode:index];
    [_cameraClient getCurrentColorMode];
}
- (void)setOverlayName:(bool)bNameOn time:(bool)bTimeOn posi:(bool)bGPSOn speed:(bool)bSpeed {
    [_cameraClient setOverlayWithName:bNameOn time:bTimeOn gps:bGPSOn speed:bSpeed];
    [_cameraClient getOverlayState];
}
- (void)setMicMute:(bool)bMute gain:(int)gain {
    [_cameraClient setMic:bMute gain:gain];
//    [_cameraClient GetMicState];
}
- (void)syncTime:(long)time zone:(int)timezone {
    [_cameraClient syncTime:(long)time zone:timezone];
}
- (void)synchronizeDateTime {
    NSDate *now = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    int zoneSec = (int)[zone secondsFromGMTForDate:now];
    [self syncTime:[now timeIntervalSince1970] zone:zoneSec];
}
- (void)setRotateParam:(BOOL)HFlip andVertical:(BOOL)VFlip {
    [_cameraClient setRotateParam:HFlip andVertical:VFlip];
}
- (void)setLiveMarkParam:(int)before after:(int)after {
    [_cameraClient setLiveMarkParam:before after:after];
}
- (void)liveMark {
    [_cameraClient doLiveMark];
}
- (void)updateWifiMode {
    [_cameraClient getWlanMode];
}
- (void)updateHostNum {
    [_cameraClient getHostNumber];
}
- (void)updateHostInfo:(int)index {
    [_cameraClient getHostInfor:index];
}
- (void)addHost:(NSString*)name password:(NSString*)pwd; {
    [_cameraClient addHost:name password:pwd];

    __weak typeof(self) weakeself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakeself.cameraClient getHostNumber];
    });

}
- (void)removeHost:(NSString*)name {
    [_cameraClient removeHost:name];

    __weak typeof(self) weakeself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakeself.cameraClient getHostNumber];
    });
}
- (void)setWifiMode:(int)mode toSSID:(NSString*)ssid {
    [_cameraClient connectHost:ssid mode:mode];
}
- (void)newFirmwareWithMD5:(NSString*)md5 {
    NSLog(@"newFWWithMD5 %@", md5);
    [_cameraClient newFirmwareVersion:md5 withURL:nil];
}
- (void)upgradeFirmware {
    [_cameraClient doUpgradeFirmware];
}

- (void)scanWiFiHost {
    [_cameraClient doScanWiFiHost];
}

- (void) connectToSSID:(NSString*)ssid {
    [_cameraClient doConnectToSSID:ssid];
}

//- (void)getBTOpened {
//    [_cameraClient getBTOpened];
//}
- (void)doBluetoothOpen:(BOOL)open {
    [_cameraClient doBTOpen:open];
}
- (void)updateOBDStatus {
    [_cameraClient updateOBDStatus];
}
- (void)updateHIDStatus {
    [_cameraClient updateHIDStatus];
}
- (void)updateVin {
    [_cameraClient updateVin];
}
- (void)doBluetoothScan {
    self.bluetoothScanState = 1;
    [_cameraClient doBTScan];
}
- (void)updateBluetoothHostNum {
    [_cameraClient updateBTHostNum];
}
- (void)updateBluetoothHostInfo:(int)index {
    [_cameraClient updateBTHostInfor:index];
}
- (void)doOBDBind:(NSString*)mac {
    self.obdConnectState = BTStatus_Busy;
    [_cameraClient doOBDBind:mac];
    _obdBindDeviceMac = mac;
}
- (void)doHIDBind:(NSString*)mac {
    self.hidConnectState = BTStatus_Busy;
    [_cameraClient doHIDBind:mac];
    _hidBindDeviceMac = mac;
}
- (void)doOBDUnBind {
    self.obdConnectState = BTStatus_Busy;
    [_cameraClient doOBDUnBind];
}

- (void)doHIDUnBind {
    self.hidConnectState = BTStatus_Busy;
    [_cameraClient doHIDUnBind];
}

- (void)doRequireLiveRawDataWithACC:(BOOL)acc GPS:(BOOL)gps OBD:(BOOL)obd {
    [_vdbClient getLiveRawDataWithACC:acc GPS:gps OBD:obd];
}
- (void)doRequireLiveDMS:(BOOL)require {
    [_vdbClient getLiveDMSData:require];
}

- (NSString*)getUpgradeDescription {
    NSString* des = nil;

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    for (NSString* item in _upgradeDescription.allKeys) {
        if ([preferredLang containsString:item]) {
            des = [NSString stringWithUTF8String:[[_upgradeDescription objectForKey:item] UTF8String]];
        }
    }
    if (des == nil) {
        des = [_upgradeDescription objectForKey:@"en"];
    }
    return des;
}

//CMD 61,76-87
- (void)formatTFCard {
    [_cameraClient formatTFCard];
}
- (void) doSetAutoPowerOffDelay:(NSString*)delay {
    [_cameraClient setAutoPowerOffDelay:delay];
}
- (void) doGetAutoPowerOffDelay {
    [_cameraClient getAutoPowerOffDelay];
}

- (void) doSetSpeakerStatus:(BOOL)enabled volume:(int)volume{
    if(enabled == self.speakerEnabled && volume == self.speakerVolume) {
        [self onSetSpeakerStatus:NO];
        return;
    }
    [_cameraClient setSpeakerStatus:enabled volume:(int)volume];
}
- (void) doGetSpeakerStatus {
    [_cameraClient onGetSpeakerStatus];
}
- (void) doSetDisplayAutoBrightness:(BOOL)autoBrightness {
    [_cameraClient setDisplayAutoBrightness:autoBrightness];
}
- (void) doGetDisplayAutoBrightness {
    [_cameraClient getDisplayAutoBrightness];
}
- (void) doSetDisplayBrightness:(int)brightnessLevel {
    [_cameraClient setDisplayBrightness:brightnessLevel];
}
- (void) doGetDisplayBrightness {
    [_cameraClient getDisplayBrightness];
}
- (void) doSetDisplayAutoOffTime:(NSString*)autoOffTime {
    [_cameraClient setDisplayAutoOffTime:autoOffTime];
}
- (void) doGetDisplayAutoOffTime {
    [_cameraClient getDisplayAutoOffTime];
}
- (void)factoryReset {
    [_cameraClient factoryReset];
}

- (void)downloadLogWithProgress:(nullable void (^)(float progress))progressHandler
                    destination:(nullable NSURL * (^)(void))destination
                    date:(NSString*)date
              completionHandler:(nullable void (^)(BOOL finished, NSURL * __nullable filePath, NSError * __nullable error))completionHandler {
    self.logProgressHandler = progressHandler;
    self.logCompletionHandler = completionHandler;

    if (destination) {
        self.logDestination = nil;
        self.logDestination = destination;
    }
    else {
        self.logDestination = ^{
            return [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"camera_log.zip"];
        };
    }

  // [self copyLog];
   [self copyLog:date];
}

- (void)downloadDebugLogWithProgress:(nullable void (^)(float progress))progressHandler
                    destination:(nullable NSURL * (^)(void))destination
              completionHandler:(nullable void (^)(BOOL finished, NSURL * __nullable filePath, NSError * __nullable error))completionHandler {
    self.logProgressHandler = progressHandler;
    self.logCompletionHandler = completionHandler;

    if (destination) {
        self.logDestination = nil;
        self.logDestination = destination;
    }
    else {
        self.logDestination = ^{
            return [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"camera_debug_log.zip"];
        };
    }

  // [self copyLog];
   [self copyDebugLog];
}

- (void)resetForDownloadingLog {
    self.logProgressHandler = nil;
    self.logDestination = nil;
    self.logCompletionHandler = nil;

    _logDownloader.delegate = nil;
    self.logDownloader = nil;
}

- (void) doGetConnectedClientsCount {
    [_cameraClient getConnectedClientsCount];
}

- (void) doGetBitrate {
    [_cameraClient getCurrentQuality];
}

- (void) doGetScreenSaverStyle {
    [_cameraClient getScreenSaverStyle];
}
- (void) doSetScrrenSaverStyle:(NSString*)style {
    [_cameraClient setScreenSaverStyle:style];
}

- (void)notifyConnectionReady {
    if (self.isReady) {
        _vdbClient.needDewarp = (self.productSerie == WLProductSerieHorn);
        [_clipsAgent onVDBState:_vdbClient.isReady];
        [_delegate onDeviceConnected:self];
        [_vdbClient setOptionsNoDelay];
        [self updateAllInfor];
        [self updateStorageSpaceInfo];
    }
}

-(void)getCameraServerAddress {
    [_cameraClient get360Server];
}

-(void)setCameraServer:(NSString *)address {
    [_cameraClient set360Server:address];
}

-(void)getPassword {
    [_cameraClient getKey];
}

-(void)copyLog:(NSString *)day {
    [_cameraClient copyLog:day];
}

-(void)copyDebugLog{
    [_cameraClient copyDebugLog];
}

-(void)setMountConfig:(NSDictionary *)mountConfig{
    [_cameraClient setMountConfig:mountConfig];
}

-(void)getMountVersion {
    [_cameraClient getMountVersion];
}
-(void)getMonitorMode {
    [_cameraClient getMonitorMode];
}
-(void)setHDRMode:(WLCameraHDRMode)mode{
    [_cameraClient setHDRMode:mode];
}
-(void)getHDRMode {
    [_cameraClient getHDRMode];
}

// api 1.9
- (void)getMountAccelLevels {
    [_cameraClient getMountAccelLevels];
}
- (void)setMountAccelLevel:(NSString*)level {
    [_cameraClient setMountAccelLevel:level];
}
- (void)getMountAccelParam:(NSString*)level {
    [_cameraClient getMountAccelParam:level];
}
- (void)setMountAccelForLevel:(NSString*)level param:(NSString*)param {
    [_cameraClient setMountAccelForLevel:level Param:param];
}

- (void)getIIOEventDetectionParam {
    [_cameraClient getIIOEventDetectionParam];
}
- (void)setIIOEventDetectionParam:(NSString*)param {
    [_cameraClient setIIOEventDetectionParam:param];
}

- (void)syncTimeEx:(long)timeSince1970 zone:(int)zoneInSec daylightSaving:(BOOL)bSaving {
    [_cameraClient syncTimeEx:timeSince1970 Zone:zoneInSec DaylightSaving:bSaving];
}
- (void)getTimeZone {
    [_cameraClient getTimeZone];
}

- (void)getMarkStorageOptions {
    [_cameraClient getMarkStorageOptions];
}
- (void)setMarkStorage:(int)gb {
    [_cameraClient setMarkStorage:gb];
}

- (void)getAudioPromptEnabled {
    [_cameraClient getAudioPromptEnabled];
}
- (void)setAudioPromptEnabled:(BOOL)audioPromptEnabled {
    [_cameraClient setAudioPromptEnabled:audioPromptEnabled];
}

// api 1.9 done

// api 1.10
- (void)getLTEStatus {
    [_cameraClient getLTEStatus];
}

- (void)getRadarSensitivity {
    [_cameraClient getRadarSensitivity];
}
- (void)setRadarSensitivity:(int)level {
    [_cameraClient setRadarSensitivity:level];
}

- (void)doDebugProps:(BOOL)setOrGet prop:(NSString*)prop action:(NSString*)action value:(NSString*)value key:(NSString*)key {
    [_cameraClient doDebugProps:setOrGet prop:prop action:action value:value key:key];
}
// api 1.10 done

// api 1.12
- (void)getMountACCTrust {
    [_cameraClient getMountACCTrust];
}

- (void)setMountACCTrust:(BOOL)trusted {
    [_cameraClient setMountACCTrust:trusted];
    [_cameraClient getMountACCTrust];
}
// api 1.12 done

// api 1.13
- (void)getAppKeepAlive {
    [_cameraClient getAppKeepAlive];
}

- (void)setAppKeepAlive:(BOOL)keep {
    [_cameraClient setAppKeepAlive:keep];
}

- (void)getAttitude {
    [_cameraClient getAttitude];
}

- (void)setAttitude:(BOOL)upsidedown {
    [_cameraClient setAttitude:upsidedown];
}
// api 1.13 done

// api 1.13.06
- (void)getSupportUpsideDown {
    [_cameraClient getSupportUpsideDown];
}
// api 1.13.06 done

// api 1.14

- (void)getSupportRiskDriveEvent {
    [_cameraClient getSupportRiskDriveEvent];
}

- (void)setSupportRiskDriveEvent:(BOOL)supported {
    [_cameraClient setSupportRiskDriveEvent:supported];
}

- (void)doGetAPN {
    [_cameraClient getAPN];
}

- (void)doSetAPN:(NSString *)apn {
    if (apn != nil && [apn length] != 0) {
        [_cameraClient setAPN:apn];
    }
}

- (void)getSupportWlanMode {
    [_cameraClient getSupportWlanMode];
}

- (void)doGetProtectionVoltage {
    [_cameraClient getProtectionVoltage];
}

- (void)doSetProtectionVoltage:(int)voltage {
    [_cameraClient setProtectionVoltage:voltage];
}

- (void)doGetParkSleepDelay {
    [_cameraClient getParkSleepDelay];
}

- (void)doSetParkSleepDelay:(int)delaySeconds {
    [_cameraClient setParkSleepDelay:delaySeconds];
}

- (void)doGetSubStreamOnly {
    [_cameraClient getSubStreamOnly];
}

- (void)doSetSubStreamOnly:(BOOL)isOnly {
    [_cameraClient setSubStreamOnly:isOnly];
}

- (void)doGetQuality {
    [_cameraClient getCurrentQuality];
}

- (void)doGetObdWorkModeConfig {
    [_cameraClient getObdWorkModeConfig];
}

- (void)doSetObdWorkModeConfig:(WLObdWorkModeConfig *)config {
    [_cameraClient setObdWorkModeConfig:config];
    [_cameraClient getObdWorkModeConfig];
}

- (void)doGetAdasConfig {
    [_cameraClient getAdasModeConfig];
}

- (void)doSetAdasConfig:(WLAdasConfig *)config {
    [_cameraClient setAdasConfig:config];
    [_cameraClient getAdasModeConfig];
}

- (void)doGetVirtualIgnitionConfig {
    [_cameraClient getAdasModeConfig];
}

- (void)doSetVirtualIgnitionConfigWithEnable:(BOOL)enable {
    [_cameraClient setVirtualIgnitionConfigWithEnable:enable];
}

- (void)doGetAuxConfig {
    [_cameraClient getAuxConfig];
}

- (void)doSetAuxConfig:(int)angle {
    [_cameraClient setAuxConfig:angle];
}

// api 1.14 done

#pragma mark - CClientConnectionDelegate

- (void)socketClientDidConnect:(nonnull WLSocketClient *)client {
    if ([client isEqual:_dmsClent]) {
        self.hasDmsCamera = YES;
    }
    else {
        if ([client isEqual:_cameraClient]) {
            bCameraClientConnected = YES;
            [self getSN];
            [_cameraClient getCameraName];
        }

        if ([client isEqual:_vdbClient]) {
            bVDBClientConnected = YES;
            [_vdbClient setSpaceDelegate:self];
        }

        [self notifyConnectionReady];
    }
}

- (void)socketClient:(nonnull WLSocketClient *)client didDisconnectWithError:(nullable NSError *)err {
    if ([client isEqual:_cameraClient]) {
        bCameraClientConnected = NO;
        [_delegate onDeviceDisconnected:self];
    }

    if ([client isEqual:_vdbClient]) {
        bVDBClientConnected = NO;
        [_delegate onDeviceDisconnected:self];
        if (err != nil) {
            NSLog(@"VDB is Disconnect with err: %@", err);
        }
    }
}

#pragma mark - WLCameraClientDelegate
// called by CameraClient

- (WLCommunicationProtocolVersion)protocolVersion {
    return self.communicationProtocolVersion;
}

- (void)onCameraName:(char*)name {
    NSLog(@"onCameraName: %@", [NSString stringWithCString:name encoding:NSUTF8StringEncoding]);
    NSString *newName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    if ([newName isEqualToString:@"No Named"]) {
        newName = @"Waylens Camera";
    }
    if (![newName isEqualToString:_name]) {
        if (_name == nil) {
            _name = newName;
             [self notifyConnectionReady];
        } else {
            _name = newName;
        }
    }
    [_delegate onDevice:self NameChanged:newName];
}

- (void)onGetApiVersion:(const char*)version {
    if (_apiVersion == nil) {
        self.apiVersion = [NSString stringWithUTF8String:version];
        _majVersion = [_apiVersion intValue];
        NSRange range = [_apiVersion rangeOfString:@"."];
        if (range.length == 1) {
            _minVersion =[[_apiVersion substringFromIndex:range.location+1] intValue];
        }
        NSRange range2 = [[_apiVersion substringFromIndex:range.location+1] rangeOfString:@"."];
        if (range2.length == 1) {
            _buildVersion =[[[_apiVersion substringFromIndex:range.location+1] substringFromIndex:range2.location+1] intValue];
        }
    }
    [self goonGetAllInfor];
}
//- (void)onCameraMode:(eCameraMode)mode {
//    if (_cameraMode != mode) {
//        self.cameraMode = mode;
//    }
//}
- (void)onRecordState:(WLRecordState)state {
    if (_recState != state) {
        self.recState = state;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CMD_Cam_get_State_result" object:self];
    }
}
- (void)onRecordingTime:(unsigned int)time {
    [_delegate onDevice:self recTime:time];
}
- (void)onPowerSupplyState:(int)state {
    BOOL charge = (state == 1);
    self.isCharging = charge;
}

- (void)onBatteryVolume:(int)mV percentage:(int)percentage {
    self.batteryState = percentage;
}
- (void)onBatteryInfo:(NSDictionary *)info percentage:(int)percentage {
    self.batteryInfo = [[WLBatteryInfo alloc] initWithDictionary:info];
    self.batteryState = percentage;
    [self notifyUpdate];
}

- (void)onStorageState:(WLStorageState)state format:(NSString *)format{
//    if (_storageState != state) {
    self.storageState = state;
    self.format = format;
//    }
}
- (void)onStorageSpace:(unsigned long long)all free:(unsigned long long)free {
    if (_markedMB == -1) {
        self.totalMB = @(all).Bytes.toMBytes.intValue;
        self.freeMB = @(free).Bytes.toMBytes.intValue;
    }
}
- (void)onMicEnabled:(BOOL)is volume:(int)volume {
    self.isMute = (is == NO);
    self.micLevel = volume;
}

- (void)onSupportedResolutionList:(unsigned long long)result {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:Video_Resolution_num];
    for (int i = 0; i < [allResolutionList count]; i++) {
        if((((unsigned long long)0x1 << i) & result) != 0){
            WLCameraSettingsListItem* item = [WLCameraSettingsListItem itemWithTitle:allResolutionList[i] value:i];
            [arr addObject:item];
        }
    }
    _resolutionList = [NSArray arrayWithArray:arr];
}
- (void)onSupportedQualityList:(unsigned long long)result {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:Video_Quality_num];
    for (int i = 0; i < [allQualityList count]; i++) {
        if((((unsigned long long)0x1 << i) & result) != 0){
            WLCameraSettingsListItem* item = [WLCameraSettingsListItem itemWithTitle:allQualityList[i] value:i];
            [arr addObject:item];
        }
    }
    _qualityList = [NSArray arrayWithArray:arr];
}
- (void)onSupportedColorModeList:(unsigned long long)result {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:Color_Mode_num];
    for (int i = 0; i < [allColorModeList count]; i++) {
        if((((unsigned long long)0x1 << i) & result) != 0){
            WLCameraSettingsListItem* item = [WLCameraSettingsListItem itemWithTitle:allColorModeList[i] value:i];
            [arr addObject:item];
        }
    }
    _colorModeList = [NSArray arrayWithArray:arr];
}
- (void)onSupportedRecModeList:(unsigned long long)result {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:Rec_Mode_num];
    for (int i = 0; i < [allRecordModeList count]; i++) {
        if((((unsigned long long)0x1 << i) & result) != 0){
            WLCameraSettingsListItem* item = [WLCameraSettingsListItem itemWithTitle:allRecordModeList[i] value:i];
            [arr addObject:item];
        }
    }
    _recordModeList = [NSArray arrayWithArray:arr];
}

- (void)onCurrentQuality:(int)index {
    [self willChangeValueForKey:@"quality"];
    _quality = (WLVideoQuality)index;
    [self didChangeValueForKey:@"quality"];
}

- (void)onGetMainQuality:(int)mainQuality subQuality:(int)subQuality {
    if (_quality != mainQuality) {
        [self willChangeValueForKey:@"quality"];
        _quality = (WLVideoQuality)mainQuality;
        [self didChangeValueForKey:@"quality"];
    }

    if (_subQuality != subQuality) {
        [self willChangeValueForKey:@"subQuality"];
        _subQuality = (WLVideoQuality)subQuality;
        [self didChangeValueForKey:@"subQuality"];
    }
}

- (void) onGetMainBitrate:(double)mainBitrate secondBitrate:(double)secondBitrate {
    self.mainBitrate = mainBitrate;
    self.secondBitrate = secondBitrate;
}

- (void)onCurrentResolution:(int)index {
    [self willChangeValueForKey:@"resolution"];
    _resolution = (eVideoResolution)index;
    [self didChangeValueForKey:@"resolution"];
}
- (void)onCurrentRecMode:(int)index {
    [self willChangeValueForKey:@"recMode"];
    _recMode = (WLRecordMode)index;
    [self didChangeValueForKey:@"recMode"];
}
- (void)onCurrentColorMode:(int)index {
    [self willChangeValueForKey:@"colorMode"];
    _colorMode = (eColorMode)index;
    [self didChangeValueForKey:@"colorMode"];
}

- (void)onOverlayInfoName:(BOOL)bName time:(BOOL)bTime posi:(BOOL)bPosi speed:(BOOL)bSpeed {
    _isShowOverlayName = bName;
    _isShowOverlayTime = bTime;
    _isShowOverlayGPS  = bPosi;
    _isShowOverlaySpeed = bSpeed;
    self.isOverlayConfigChanged = (bName << 3) | (bTime << 2) | (bPosi << 1) | bSpeed;
}

- (void)onRotateMode:(WLCameraRotateMode)mode rotated:(BOOL)rotated{
    _rotationMode = mode;
    //self.isRotated = rotated;
//    if ([self.settingsDelegate respondsToSelector:@selector(onSetRotateMode:)]) {
//        [self.settingsDelegate onSetRotateMode:mode];
//    }
}

- (void)onLiveMarkParam:(int)before After:(int)after {
    _liveMarkBeforeSec = before;
    _liveMarkAfterSec = after;
    _vdbClient.markBefore = before;
    _vdbClient.markAfter = after;
    self.isLiveMarkTimeChanged = _liveMarkBeforeSec << 16 | _liveMarkAfterSec;
}
- (void)onGetWiFiMode:(int)mode SSID:(NSString*)ssid {
    _wifiMode = (Wifi_Mode)mode;
}
- (void)onGetWiFiHostNum:(int)num {
    _wifiHostNum = num;
    [_wifiHostList removeAllObjects];
    for (int i = 0; i < num; i++) {
        [_cameraClient getHostInfor:i];
    }
}
- (void)onGetWiFiHostInfor:(NSString*)name {
    [_wifiHostList addObject:name];
    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onWiFiHostListChanged:)]) {
        [self.settingsDelegate onWiFiHostListChanged:_wifiHostList];
    }
}

- (void)onRecErr:(NSError*)err {
    [_delegate onDevice:self recErr:err];
}
- (void)onLiveMark:(BOOL)done {
    [_delegate onLiveMark:done];
}

- (void)onCurrentDevice:(NSString*)sn FW:(NSString*)vFw hardware:(NSString*)vHw {
    if ([sn isEqualToString:@""]) {
        sn = [NSString stringWithFormat:@"NA"];
    }
    if (_sn != nil) {
        if (![_sn isEqualToString:sn]) {
            NSLog(@"Different camera on the same address");
            [_delegate onDeviceDisconnected:self];
        }
        return;
    }
    NSLog(@"onCurrentDevice(%@, %@): %@", sn, vHw, vFw);
    _sn = sn;
    _firmwareVersion = vFw;

    _productSerie = [WLCameraDevice determineProductSerieWithHardwareVersion:vHw];

    if (_productSerie == WLProductSerieUnknown && vHw != NULL) {

    }

    if (vHw == NULL) {
        NSLog(@"get a wrong version: %@", vHw);
        return;
    } else {
        if ([vFw isEqualToString:@"beta"]) {
            _isNeedUpgrade = YES;
            _hardwareModel = @"beta";
            _sn = @"beta";
        } else {
            _hardwareModel = vHw;
        }
    }
    
    [self notifyConnectionReady];
}

- (void)onReadyToUpgrade {
    if (_firmwareUpgradeDelegate) {
        [_firmwareUpgradeDelegate onReadyToUpgrade];
    }
}
- (void)onUpgradeResult:(int)process {
    if (_firmwareUpgradeDelegate) {
        [_firmwareUpgradeDelegate onUpgradeResult:process];
    }
}

- (void)onTransferFirmware:(int)state size:(int)firmwareSize progress:(int)progress errorCode:(int)errorCode {
    [self.firmwareUpgradeDelegate onTransferFirmware:state size:firmwareSize progress:progress errorCode:errorCode];
}

//1.2
- (void)onBTisSupported:(BOOL)bSupported {
    _isSupportBluetooth = bSupported;
}
- (void)onBTisEnabled:(BOOL)bEnabled {
    self.isBluetoothOpen = bEnabled;
    if (bEnabled) {
        __weak typeof(self) weakeself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakeself updateOBDStatus];
            [weakeself updateHIDStatus];
        });
    }
}
- (void)removeBindedOBDDeviceFromList {
    for (NSDictionary* dict in _obdHostList) {
        if ([dict[@BTMacKey] isEqualToString:_obdBindDeviceMac]) {
            [_obdHostList removeObject:dict];
            break;
        }
    }
}
- (void)removeBindedHIDDeviceFromList {
    for (NSDictionary* dict in _hidHostList) {
        if ([dict[@BTMacKey] isEqualToString:_hidBindDeviceMac]) {
            [_hidHostList removeObject:dict];
            break;
        }
    }
}
- (void)onGetBTDevType:(eBTType)type Status:(WLBluetoothStatus)status Mac:(NSString*)deviceMac Name:(NSString*)name {
    if (type == BTType_OBD) {
        _obdBindDeviceMac = [deviceMac isEqualToString:@"NA"] ? nil : [NSString stringWithString:deviceMac];
        _obdBindDeviceName = [NSString stringWithString:name];
        if(self.obdConnectState != status) {
            self.obdConnectState = status;
            if ((_majVersion >= 1) && (_minVersion >= 5)) {
                if (status == BTStatus_ON) {
                    [self updateVin];
                } else {
                    self.vehicleIdentifyNum = nil;
                }
            }
        }
        if (status == BTStatus_OFF && _obdBindDeviceMac) {
            self.obdConnectState = BTStatus_Wait;
        }
    }
    if (type == BTType_HID) {
        _hidBindDeviceMac = [deviceMac isEqualToString:@"NA"] ? nil : [NSString stringWithString:deviceMac];
        _hidBindDeviceName = [NSString stringWithString:name];
        self.hidConnectState = status;
        if (status == BTStatus_OFF && _hidBindDeviceMac) {
            self.hidConnectState = BTStatus_Wait;
        }
    }
}
- (void)onGetBTDevHostNum:(int)num {
    [_obdHostList removeAllObjects];
    [_hidHostList removeAllObjects];
    [_otherBluetoothList removeAllObjects];
    if (num == 0) {
        self.bluetoothScanState = 3;
    } else {
        _bluetoothHostNum = num;
        for (int i = 0; i < num; i++) {
            [_cameraClient updateBTHostInfor:i];
        }
    }
}
- (void)onGetBTDevHostInfor:(NSString*)name Mac:(NSString*)mac {
    NSMutableArray* arr;
    NSRange range = [[name uppercaseString] rangeOfString:@"OBD"];
    if (range.length > 0) {
        arr = _obdHostList;
    } else {
        arr = _hidHostList;
    }
    for (NSDictionary* dic in arr) {
        if ([[dic objectForKey:@BTNameKey] isEqualToString:name] && [[dic objectForKey:@BTMacKey] isEqualToString:mac]) {
            return;
        }
    }
    [arr addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, mac, nil]
                                               forKeys:[NSArray arrayWithObjects:@BTNameKey, @BTMacKey, nil]]];
    if (_obdHostList.count + _hidHostList.count == _bluetoothHostNum) {
        self.bluetoothScanState = 3;
    }
}
- (void)onGetBTList:(NSDictionary*)list {
    [_obdHostList removeAllObjects];
    [_hidHostList removeAllObjects];
    [_otherBluetoothList removeAllObjects];
    if (list && [list objectForKey:@"Devices"]) {
        for (NSDictionary* dev in [list objectForKey:@"Devices"]) {
            NSString* name = [dev objectForKey:@"name"];
            NSString* mac = [dev objectForKey:@"mac"];
            if (name && mac) {
                NSRange range = [[name uppercaseString] rangeOfString:@"OBD-"];
                if (range.length > 0 && range.location == 0) {
                    if (![_obdBindDeviceMac isEqualToString:mac]) {
                        [_obdHostList addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, mac, nil]
                                                                            forKeys:[NSArray arrayWithObjects:@BTNameKey, @BTMacKey, nil]]];
                    }
                    continue;
                }
                range = [[name uppercaseString] rangeOfString:@"RC-"];
                if (range.length > 0 && range.location == 0) {
                    if ([_hidBindDeviceMac isEqualToString:mac] == NO) {
                        [_hidHostList addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, mac, nil]
                                                                            forKeys:[NSArray arrayWithObjects:@BTNameKey, @BTMacKey, nil]]];
                    }
                    continue;
                }
                [_otherBluetoothList addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, mac, nil]
                                                                    forKeys:[NSArray arrayWithObjects:@BTNameKey, @BTMacKey, nil]]];
            }
        }
    }
    self.bluetoothScanState = 3;
}
- (void)onBTDevScanDone:(int)done withList:(NSDictionary*)list {
    switch (done) {
        case 0: {
            self.bluetoothScanState = 2;
            if (list) {
                [self onGetBTList:list];
            } else {
                _bluetoothHostNum = 0;
                [_cameraClient updateBTHostNum];
            }
        }
            break;
        case 2: {
            self.bluetoothScanState = -2;
            if (list) {
                [self onGetBTList:list];
            } else {
                _bluetoothHostNum = 0;
                [_cameraClient updateBTHostNum];
            }
        }

        default: {
            _bluetoothHostNum = 0;
            self.bluetoothScanState = -1;
        }
            break;
    }
}
- (void)onBTDev:(eBTType)type BindDone:(int) result {
    if (type == BTType_OBD) {
        [self removeBindedOBDDeviceFromList];
        [_cameraClient updateOBDStatus];
    }
    if (type == BTType_HID) {
        [self removeBindedHIDDeviceFromList];
        [_cameraClient updateHIDStatus];
    }
}
- (void)onBTDev:(eBTType)type UnBindDone:(int) result {
    if (type == BTType_OBD) {
        if (result == 0) {
            _obdBindDeviceMac = nil;
            _obdBindDeviceName = nil;
            self.obdConnectState = BTStatus_OFF;
        } else {
            [self.cameraClient updateOBDStatus];
        }
    }
    if (type == BTType_HID) {
        if (result == 0) {
            _hidBindDeviceMac = nil;
            _hidBindDeviceName = nil;
            self.hidConnectState = BTStatus_OFF;
        } else {
            [self.cameraClient updateHIDStatus];
        }
    }
}
//end 1.2
+ (WLBluetoothStatus)btDevStatusFromString:(NSString*)s {
    if ([s isEqualToString:@"on"]) {
        return BTStatus_ON;
    } else if ([s isEqualToString:@"off"]) {
        return BTStatus_OFF;
    } else if ([s isEqualToString:@"connecting"]) {
        return BTStatus_Busy;
    } else {
        return BTStatus_Wait;
    }
}
- (void)ongetBTInfoWithSupported:(BOOL)bSupported
                         enabled:(BOOL)bEnabled
                        scanning:(BOOL)isScanning
                       OBDStatus:(NSString*)obdStatus
                         OBDName:(NSString*)obdName
                          OBDMac:(NSString*)obdMac
                       HIDStatus:(NSString*)hidStatus
                         HIDName:(NSString*)hidName
                          HIDMac:(NSString*)hidMac
                       HIDBatLev:(int)hidBatLev {

    _isSupportBluetooth = bSupported;
    _isBluetoothOpen = bEnabled;
    _bluetoothScanState = ((_bluetoothScanState == 1) || (_bluetoothScanState == 3))
                        ? (isScanning ? 1 : 3)
                        : (isScanning ? 1 : 0);
    [self onGetBTDevType:BTType_OBD Status:[WLCameraDevice btDevStatusFromString:obdStatus] Mac:obdMac Name:obdName];
    [self onGetBTDevType:BTType_HID Status:[WLCameraDevice btDevStatusFromString:hidStatus] Mac:hidMac Name:hidName];
    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(ongetBTInfoWithSupported:enabled:scanning:OBDStatus:OBDName:OBDMac:HIDStatus:HIDName:HIDMac:HIDBatLev:)]) {
        [self.settingsDelegate ongetBTInfoWithSupported:bSupported
                                                enabled:bEnabled
                                               scanning:isScanning
                                              OBDStatus:[WLCameraDevice btDevStatusFromString:obdStatus]
                                                OBDName:obdName
                                                 OBDMac:obdMac
                                              HIDStatus:[WLCameraDevice btDevStatusFromString:hidStatus]
                                                HIDName:hidName
                                                 HIDMac:hidMac
                                              HIDBatLev:hidBatLev];
    }
}

//CMD 61,76-87 delegate callback methods
- (void) onFormatTFCard:(BOOL)success{
    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onFormatTFCard:)]) {
        [self.settingsDelegate onFormatTFCard:success];
    }
}

- (void) onSetAutoPowerOffDelay:(BOOL)success {
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onSetAutoPowerOffDelay:)]) {
//        [self.settingsDelegate onSetAutoPowerOffDelay:success];
//    }
}
- (void) onGetAutoPowerOffDelay:(NSString*)delay {
    self.autoPowerOffDelay = delay;
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onGetAutoPowerOffDelay:)]) {
//        [self.settingsDelegate onGetAutoPowerOffDelay:delay];
//    }
}

- (void) onSetSpeakerStatus:(BOOL)success {
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onSetSpeakerStatus:)]) {
//        [self.settingsDelegate onSetSpeakerStatus:success];
//    }
}
- (void) onGetSpeakerStatus:(BOOL)enabled volume:(int)volume {
    self.speakerEnabled = enabled;
    self.speakerVolume = volume;
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onGetSpeakerStatus:volume:)]) {
//        [self.settingsDelegate onGetSpeakerStatus:enabled volume:volume];
//    }
}

- (void) onSetDisplayAutoBrightness:(BOOL)success {
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onSetDisplayAutoBrightness:)]) {
//        [self.settingsDelegate onSetDisplayAutoBrightness:success];
//    }
}
- (void) onGetDisplayAutoBrightness:(BOOL)autoBrightness {
    self.displayAutoBrightness = autoBrightness;
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onGetDisplayAutoBrightness:)]) {
//        [self.settingsDelegate onGetDisplayAutoBrightness:autoBrightness];
//    }
}

- (void) onSetDisplayBrightness:(BOOL)success {
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onSetDisplayBrightness:)]) {
//        [self.settingsDelegate onSetDisplayBrightness:success];
//    }
}
- (void) onGetDisplayBrightness:(int)brightnessLevel {
    self.displayBrightness = brightnessLevel;
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onGetDisplayBrightness:)]) {
//        [self.settingsDelegate onGetDisplayBrightness:brightnessLevel];
//    }
}

- (void) onSetDisplayAutoOffTime:(BOOL)success {
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onSetDisplayAutoOffTime:)]) {
//        [self.settingsDelegate onSetDisplayAutoOffTime:success];
//    }
}
- (void) onGetDisplayAutoOffTime:(NSString*)autoOffTime {
    self.displayAutoOffTime = autoOffTime;
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onGetDisplayAutoOffTime:)]) {
//        [self.settingsDelegate onGetDisplayAutoOffTime:autoOffTime];
//    }
}

- (void) onFactoryReset:(BOOL)success {
    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onFactoryReset:)]) {
        [self.settingsDelegate onFactoryReset:success];
    }
}

- (void) onGetConnectedClientsCount:(int)count {
    self.connectedClientCount = count;
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onGetConnectedClientsCount:)]) {
//        [self.settingsDelegate onGetConnectedClientsCount:count];
//    }
}
- (void)onGetDevieTime:(int)time timeZone:(int)sec {
    NSDate *now = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: now];
    NSInteger delta = time - [now timeIntervalSince1970];
    if (interval != -1 * sec || (delta > 60 || delta < -60)) {
        // timezone from linux is seconds west of UTC
        [self syncTime:[now timeIntervalSince1970] zone:(int)interval];
    }
}
//CMD 61,76-87
- (void)onGetVIN:(NSString*)vin {
    if (![vin isEqualToString:@""]) {
        self.vehicleIdentifyNum = vin;
        NSLog(@"get VIN: %@", vin);
    }
}

- (void) onGetScreenSaverStyle:(NSString *)style {
    self.screenSaverStyle = style;
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onGetScreenSaverStyle:)]) {
//        [self.settingsDelegate onGetScreenSaverStyle:style];
//    }
}

- (void) onSetScreenSaverStyle:(BOOL)success {
//    if(self.settingsDelegate && [self.settingsDelegate respondsToSelector:@selector(onSetScreenSaverStyle:)]) {
//        [self.settingsDelegate onSetScreenSaverStyle:success];
//    }
}

- (void)onGetAchtServer:(BOOL)bTest {
    _isConnect2TestAchtServer = bTest;
}

-(void)onGetKey:(NSString *)key{
    _password = key;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetPassword:)]) {
        [self.settingsDelegate onGetPassword:key];
    }
}

-(void)onCopyLog:(BOOL)success{
    NSLog(@"log archived and ready for transfer");
    
    if (_logDownloader == nil) {
        self.logDownloader = [[WLCameraLogDownloader alloc] initWithIP:[self getIP] port:10098];
        _logDownloader.delegate = self;
    }

    if (_logDestination) {
        [_logDownloader downloadToFile:_logDestination()];
    }
    else {
        if (_logCompletionHandler) {
            self.logCompletionHandler(false, nil, [[NSError alloc] initWithDomain:@"DownloadingCameraLogError" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Log downloading destination is nil."}]);
        }
    }
}


-(void)onCopyDebugLog:(BOOL)success{
    NSLog(@"log archived and ready for transfer");
    
    if (_logDownloader == nil) {
        self.logDownloader = [[WLCameraLogDownloader alloc] initWithIP:[self getIP] port:10099];
        _logDownloader.delegate = self;
    }

    if (_logDestination) {
        [_logDownloader downloadToFile:_logDestination()];
    }
    else {
        if (_logCompletionHandler) {
            self.logCompletionHandler(false, nil, [[NSError alloc] initWithDomain:@"DownloadingCameraDebugLogError" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Log downloading destination is nil."}]);
        }
    }
}

-(void)onGet360Server:(NSString *)address{
    _serverAddress = address;
}

-(void)onSet360Server:(BOOL)success{
    if (success) {
        [self.cameraClient get360Server];
    }
}

-(void)onSetMountConfig:(BOOL)success{
    if (success) {
        [self.cameraClient getMountConfig];
    }
}

-(void)onGetMountConfig:(NSDictionary *)dict{
    _mountConfig = dict;
    if([self.settingsDelegate respondsToSelector:@selector(onGetMountConfig:)]) {
        [self.settingsDelegate onGetMountConfig:dict];
    }
}

-(void)onGetMountVersion:(NSDictionary *)dict {
    _isSupport4g = [dict[@"support_4g"] boolValue];
    _mountHardwareModel = dict[@"hw_version"];
    _mountFirmwareVersion = dict[@"sw_version"];
    if (dict[@"vercode"] && ![dict[@"vercode"] isEqualToString:@"unknown"]) {
        _mountVersionCode = [dict[@"vercode"] intValue];
    } else {
        _mountVersionCode = 0;
    }
    int validcode = _mountVersionCode >> 8;
    if ((validcode == 0) ||
        (validcode == 0x7) ||
        (validcode == 0x6)) {
        _isSupportRadarSensitivity = false;
    } else {
        _isSupportRadarSensitivity = true;
    }
}

-(void)onGetMonitorMode:(NSString *)mode {
    [self willChangeValueForKey:@"isParking"];
    _isParking = [mode isEqualToString:@"park"];
    [self didChangeValueForKey:@"isParking"];
    [self notifyUpdate];
}
-(void)onSetHDRMode:(BOOL) success{
    if (success) {
        [self getHDRMode];
    }
}
-(void)onGetHDRMode:(WLCameraHDRMode)mode {
    _hdrMode = mode;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetHDRMode:)]) {
        [self.settingsDelegate onGetHDRMode:mode];
    }
}

-(void)notifyUpdate {
    [self.delegate onDeviceUpdated:self];
}

// api 1.9
- (void)onGetMountAccelLevels:(NSArray*)levels current:(NSString*)current {
    _accelerometerLevel = current;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetMountAccelLevels:current:)]) {
        [self.settingsDelegate onGetMountAccelLevels:levels current:current];
    }
}
- (void)onSetMountAccelLevel:(BOOL)result {
    if ([self.settingsDelegate respondsToSelector:@selector(onSetMountAccelLevel:)]) {
        [self.settingsDelegate onSetMountAccelLevel:result];
    }
}

// for debug
- (void)onGetMountAccelParam:(NSString*)param {
    if ([self.settingsDelegate respondsToSelector:@selector(onGetMountAccelParam:)]) {
        [self.settingsDelegate onGetMountAccelParam:param];
    }
}
- (void)onSetMountAccelParam:(BOOL)result {
    if ([self.settingsDelegate respondsToSelector:@selector(onSetMountAccelParam:)]) {
        [self.settingsDelegate onSetMountAccelParam:result];
    }
}

//- (void)onSyncTimeEx:(long)timeSince1970 Zone:(int)zoneInSec DaylightSaving:(BOOL)bSaving;
- (void)onGetTimeZone:(int)zoneInSec DaylightSaving:(BOOL)bSaving {
//    if ([self.settingsDelegate respondsToSelector:@selector(onGetTimeZone:DaylightSaving:)]) {
//        [self.settingsDelegate onGetTimeZone:zoneInSec DaylightSaving:bSaving];
//    }
}

- (void)onGetMarkStorageOptions:(NSArray*)levels current:(int)currentInGB {
    if ([self.settingsDelegate respondsToSelector:@selector(onGetMarkStorageOptions:current:)]) {
        [self.settingsDelegate onGetMarkStorageOptions:levels current:currentInGB];
    }
}
- (void)onSetMarkStorage:(int)gb {
    if ([self.settingsDelegate respondsToSelector:@selector(onSetMarkStorage:)]) {
        [self.settingsDelegate onSetMarkStorage:gb];
    }
}
-(void)onSetAudioPromptEnabled:(BOOL)success {
    if (success) {
        [self getAudioPromptEnabled];
    }
}
- (void)onGetAudioPromptEnabled:(BOOL)enabled{
    self.isAudioPromptEnabled = enabled;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetAudioPromptEnabled:)]) {
        [self.settingsDelegate onGetAudioPromptEnabled:enabled];
    }
}
-(void)onGetICCID:(NSString *)iccid{
    NSLog(@"Get ICCID: %@", iccid);
    _iccid = iccid;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetICCID:)]) {
        [self.settingsDelegate onGetICCID: iccid];
    }
}

-(void)onGetLTEFirmwareVersionPublic:(NSString *)publicVersion internal:(NSString *)internalVersion {
    _lteFirmwareVersionPublic = publicVersion;
    _lteFirmwareVersionInternal = internalVersion;
    NSLog(@"Get LTE firmware verison public: %@ internal: %@", publicVersion, internalVersion);
}

-(void)onGetLTEStatus:(NSDictionary *)status {
    _lteInfo = status;
    if (_iccid.length == 0 && status[@"sim"] != nil && ![status[@"sim"] isEqualToString:@"SIM failure"]) {
        [_cameraClient getICCID];
    }
    if ([self.settingsDelegate respondsToSelector:@selector(onGetLTEStatus:)]) {
        [self.settingsDelegate onGetLTEStatus:status];
    }
}
// api 1.9 end

// api 1.10
- (void)onGetRadarSensitivity:(float)level {
    if ([self.settingsDelegate respondsToSelector:@selector(onGetRadarSensitivity:)]) {
        [self.settingsDelegate onGetRadarSensitivity:level];
    }
}
- (void)onSetRadarSensitivity:(float)level {
    if ([self.settingsDelegate respondsToSelector:@selector(onSetRadarSensitivity:)]) {
        [self.settingsDelegate onSetRadarSensitivity:level];
    }
}
- (void)onDebugProp:(NSString*)prop value:(NSString*)value {
    if ([self.settingsDelegate respondsToSelector:@selector(onDebugProp:value:)]) {
        [self.settingsDelegate onDebugProp:prop value:value];
    }
}
// api 1.10 done

// api 1.12
- (void)onGetMountACCTrust:(BOOL)trusted {
    self.isMountACCTrusted = trusted;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetMountACCTrust:)]) {
        [self.settingsDelegate onGetMountACCTrust:trusted];
    }
}
// api 1.12 done

// api 1.13
- (void)onGetAppKeepAlive:(BOOL)keep {
    self.keepAliveIfAppConnected = keep;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetAppKeepAlive:)]) {
        [self.settingsDelegate onGetAppKeepAlive:keep];
    }
}

- (void)onGetAttitude:(BOOL)isUpsideDown {
    if (self.isUpsideDown != isUpsideDown) {
        self.isUpsideDown = isUpsideDown;
        [self notifyUpdate];

        if ([self.settingsDelegate respondsToSelector:@selector(onGetAttitude:)]) {
            [self.settingsDelegate onGetAttitude:isUpsideDown];
        }
    }
}

- (void)onGetSupportUpsideDown:(BOOL)isSupported {
    self.isSupportUpsideDown = [NSNumber numberWithBool:isSupported];
    if ([self.settingsDelegate respondsToSelector:@selector(onGetSupportUpsideDown:)]) {
        [self.settingsDelegate onGetSupportUpsideDown:isSupported];
    }
}

// api 1.13 done

// api 1.14

- (void)onGetSupportRiskDriveEvent:(BOOL)supported {
    self.isSupportRiskDriveEvent = supported;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetSupportRiskDriveEvent:)]) {
        [self.settingsDelegate onGetSupportRiskDriveEvent:supported];
    }
}

- (void)onGetAPN:(NSString *)apn {
    self.apn = apn;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetAPN:)]) {
        [self.settingsDelegate onGetAPN:apn];
    }
}

- (void)onGetSupportWlanMode:(BOOL)supported {
    self.isSupportWlanMode = supported;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetSupportWlanMode:)]) {
        [self.settingsDelegate onGetSupportWlanMode:supported];
    }
}

- (void)onGetProtectionVoltage:(int)voltage {
    self.protectionVoltage = voltage;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetProtectionVoltage:)]) {
        [self.settingsDelegate onGetProtectionVoltage:voltage];
    }
}

- (void)onGetParkSleepDelay:(int)delaySeconds {
    self.parkSleepDelay = delaySeconds;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetParkSleepDelay:)]) {
        [self.settingsDelegate onGetParkSleepDelay:delaySeconds];
    }
}

- (void)onGetSubStreamOnly:(BOOL)isOnly {
    self.isSubStreamOnly = isOnly;
    if ([self.settingsDelegate respondsToSelector:@selector(onGetSubStreamOnly:)]) {
        [self.settingsDelegate onGetSubStreamOnly:isOnly];
    }
}

- (void)onSetQuality:(BOOL)success {
    if ([self.settingsDelegate respondsToSelector:@selector(onSetQuality:)]) {
        [self.settingsDelegate onSetQuality: success];
    }
}

// api 1.14 done

- (void)onGetIIOEventDetectionParam:(NSString*)param {
    if ([self.settingsDelegate respondsToSelector:@selector(onGetIIOEventDetectionParam:)]) {
        [self.settingsDelegate onGetIIOEventDetectionParam:param];
    }
}
- (void)onSetIIOEventDetectionParam:(BOOL)result {
    if ([self.settingsDelegate respondsToSelector:@selector(onSetIIOEventDetectionParam:)]) {
        [self.settingsDelegate onSetIIOEventDetectionParam:result];
    }
}

- (void)onSetHotspotInfoWithSsid:(NSString *)ssid andPassword:(NSString *)password {
    if ([self.settingsDelegate respondsToSelector:@selector(onSetHotspotInfoWithSsid:andPassword:)]) {
        [self.settingsDelegate onSetHotspotInfoWithSsid:ssid andPassword:password];
    }
}

- (void)onGetObdWorkModeConfig:(WLObdWorkModeConfig *)obdWorkModeConfig {
    if ((obdWorkModeConfig.voltageOn == nil || obdWorkModeConfig.voltageOff == nil || obdWorkModeConfig.voltageCheck == nil) && (self.obdWorkModeConfig != nil)) {
        return;
    }
    self.obdWorkModeConfig = obdWorkModeConfig;
}

- (void)onGetAdasConfig:(WLAdasConfig *)adasConfig {
    self.adasConfig = adasConfig;
}

- (void)onGetVirtualIgnitionConfigWithEnable:(BOOL)enable {
    self.isVirtualIgnitionEnabled = enable;
}

- (void)onGetAuxConfig:(WLAuxConfig *)auxConfig {
    self.auxConfig = auxConfig;
}

/////////////////////// ↓ Evcam ↓ ///////////////////////

- (void)transferFirmware:(NSData *)firmwareData size:(int)firmwareSize md5:(NSString *)md5 rebootNeeded:(BOOL)rebootNeeded {
    [_cameraClient transferFirmware:firmwareData size:firmwareSize md5:md5 rebootNeeded:rebootNeeded];
}

- (void)onGetVinMirror:(NSArray *)vinMirrorList {
    self.vinMirrorList = [NSArray arrayWithArray:vinMirrorList];
}

- (void)onGetRecordConfigList:(NSArray *)recordConfigList {
    self.recordConfigList = [NSArray arrayWithArray:recordConfigList];
}

- (void)onGetRecordConfig:(WLCameraRecordConfig *)cameraRecordConfig {
    self.recordConfig = cameraRecordConfig;
}

- (void)onBTInfo:(eBTType)type UnBindDone:(int)result {

}

- (void)doSetRecordConfig:(NSString *)recordConfig bitrateFactor:(int)bitrateFactor forceCodec:(int)forceCodec {
    [_cameraClient setRecordConfig:recordConfig bitrateFactor:bitrateFactor forceCodec:forceCodec];
}

- (void)doGetRecordConfigList {
    [_cameraClient getRecordConfigList];
}

- (void)doSetVinMirror:(NSArray *)vinMirrorList {
    [_cameraClient setVinMirror:vinMirrorList];
}

- (void)doGetVinMirror {
    [_cameraClient getVinMirror];
}

/////////////////////// ↑ Evcam ↑ ///////////////////////

#pragma mark - CameraSpaceDelegate

- (void)onGetCameraSpaceTotal:(long long)total free:(long long)free clip:(long long)clip marked:(long long)marked {
    if(total > 0) {
        self.clipMB = @(clip).Bytes.toMBytes.intValue;
        self.totalMB = @(total).Bytes.toMBytes.intValue;
        self.markedMB = @(marked).Bytes.toMBytes.intValue;
        self.freeMB = @(free).Bytes.toMBytes.intValue;
    } else {
        self.clipMB = 0;
        self.totalMB = 0;
        self.markedMB = 0;
        self.freeMB = 0;
    }
}

+ (NSArray*) supportedAutoPowerOffDelay {
    NSArray *keys = @[@"Never", @"30s", @"60s", @"2min", @"5min"];
    NSArray *names =  @[@"Never",
                        [@"30 " stringByAppendingString:@"seconds"],
                        [@"1 " stringByAppendingString:@"minute"],
                        [@"2 " stringByAppendingString:@"minutes"],
                        [@"5 " stringByAppendingString:@"minutes"]];
    return @[keys, names];
}
+ (NSArray*) supportedDisplayAutoOffTime {
    NSArray *keys = @[@"Never", @"10s", @"30s", @"60s", @"2min", @"5min"];
    NSArray *names =  @[@"Never",
                        [@"10 " stringByAppendingString:@"seconds"],
                        [@"30 " stringByAppendingString:@"seconds"],
                        [@"1 " stringByAppendingString:@"minute"],
                        [@"2 " stringByAppendingString:@"minutes"],
                        [@"5 " stringByAppendingString:@"minutes"]];
    return @[keys, names];
}

#pragma mark - WLCameraLogDownloaderDelegate

- (void)cameraLogDownloader:(WLCameraLogDownloader *)cameraLogDownloader downloadProgressDidChange:(float)progress {
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakself.logProgressHandler) {
            weakself.logProgressHandler(progress);
        }
    });
}

- (void)cameraLogDownloader:(WLCameraLogDownloader *)cameraLogDownloader downloadFinished:(BOOL)finished error:(NSError *)error {
    if (_logCompletionHandler) {
        _logCompletionHandler(finished, _logDestination(), error);
    }

    [self resetForDownloadingLog];
}

 // for mk

- (void)onGetConfigSettingMK:(NSDictionary *)mkConfig cmd:(NSString*)cmd {
    
    if ([cmd isEqualToString:@"DriverInfoCfg"])
    {
        self.ConfigDriverInfoMK = mkConfig;
       // Both strings are equal without respect to their case.
        if([self.settingsDelegate respondsToSelector:@selector(onGetConfigSettingMK:cmd:)]) {
            [self.settingsDelegate onGetConfigSettingMK:mkConfig cmd:cmd];
        }
        
    } else if ([cmd isEqualToString:@"setting_cfg"])
    {
        self.ConfigSetting_cfgMK = mkConfig;
        if([self.settingsDelegate respondsToSelector:@selector(onGetConfigSettingMK:cmd:)]) {
            [self.settingsDelegate onGetConfigSettingMK:mkConfig cmd:cmd];
        }
       // Both strings are equal without respect to their case.
    } else if ([cmd isEqualToString:@"in_out"])
    {
        self.ConfigIn_outMK = mkConfig;
        if([self.settingsDelegate respondsToSelector:@selector(onGetConfigSettingMK:cmd:)]) {
            [self.settingsDelegate onGetConfigSettingMK:mkConfig cmd:cmd];
        }
       // Both strings are equal without respect to their case.
    }
    else if ([cmd isEqualToString:@"TCVN_01"])
    {
        self.TCVN1Config = mkConfig;
        if([self.settingsDelegate respondsToSelector:@selector(onGetConfigSettingMK:cmd:)]) {
            [self.settingsDelegate onGetConfigSettingMK:mkConfig cmd:cmd];
        }
       // Both strings are equal without respect to their case.
    }
    
    else if ([cmd isEqualToString:@"TCVN_02"])
    {
        self.TCVN2Config = mkConfig;
        if([self.settingsDelegate respondsToSelector:@selector(onGetConfigSettingMK:cmd:)]) {
            [self.settingsDelegate onGetConfigSettingMK:mkConfig cmd:cmd];
        }
       // Both strings are equal without respect to their case.
    }
    else if ([cmd isEqualToString:@"TCVN_03"])
    {
        self.TCVN3Config = mkConfig;
        if([self.settingsDelegate respondsToSelector:@selector(onGetConfigSettingMK:cmd:)]) {
            [self.settingsDelegate onGetConfigSettingMK:mkConfig cmd:cmd];
        }
       // Both strings are equal without respect to their case.
    }
    
    else if ([cmd isEqualToString:@"TCVN_04"])
    {
        self.TCVN4Config = mkConfig;
        if([self.settingsDelegate respondsToSelector:@selector(onGetConfigSettingMK:cmd:)]) {
            [self.settingsDelegate onGetConfigSettingMK:mkConfig cmd:cmd];
        }
       // Both strings are equal without respect to their case.
    }
    
    else if ([cmd isEqualToString:@"TCVN_05"])
    {
        self.TCVN5Config = mkConfig;
        if([self.settingsDelegate respondsToSelector:@selector(onGetConfigSettingMK:cmd:)]) {
            [self.settingsDelegate onGetConfigSettingMK:mkConfig cmd:cmd];
        }
       // Both strings are equal without respect to their case.
    }

}



- (void) doSetConfigSettingMK:(NSDictionary *)config cmd:(NSString *)cmd {
    [_cameraClient setConfigSettingMK:config cmd:cmd];
}


- (void)doGetConfigSettingMK:(nonnull NSString *)cmd {
    [_cameraClient getConfigSettingMK:cmd];
}

@end
