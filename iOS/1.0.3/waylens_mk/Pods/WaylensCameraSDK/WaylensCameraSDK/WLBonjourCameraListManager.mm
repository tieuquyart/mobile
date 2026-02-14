//
//  DeviceManager.mm
//  Vidit
//
//  Created by gliu on 15/1/6.
//  Copyright (c) 2015年 Transee. All rights reserved.
//
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <WaylensFoundation/WaylensFoundation.h>
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>

#import "WLBonjourCameraListManager.h"
#import "WLFirmwareUpgradeManager.h"
#import "WLCameraDevice+FrameworkInternal.h"
#import "WLFirmwareUpgradeManager+FrameworkInternal.h"
#import "WLCameraVDBClient+FrameworkInternal.h"
#import "Define+FrameworkInternal.h"

#import <SystemConfiguration/CaptiveNetwork.h>
//#define ConnectStudio

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

//disconnect by socket closed
#define IgnoreBounjourServiceDisconnectEvent

static const char* _Nonnull networkChangeName = "com.apple.system.config.network_change";

NSString * const WLCurrentCameraChangeNotification = @"WLCurrentCameraChangeNotification";

@interface WLBonjourCameraListManager () <NSNetServiceBrowserDelegate, NSNetServiceDelegate, WLCameraDeviceDelegate> {
    NSNetServiceBrowser*    _pNetServieBrowserWaylens;
    NSNetServiceBrowser*    _pNetServieBrowserOld;
    NSString*               _currentWifi;

    NSString*               _carrierName;
}

@property (nonatomic, strong) WLCameraDevice* currentDevice;

@property (atomic, retain) NSMutableArray* pServices;
@property (atomic, retain) NSMutableArray* pDelegateList;
@property (atomic, retain) NSMutableArray* pZConfDevices;
@property (atomic, retain) NSMutableArray* pConnectedDevices;
@property (nonatomic, assign) BOOL wasConnected;
@property (nonatomic, strong) NSTimer* refreshTimer;

- (BOOL)hasDiscoveredAPDevice; // But not yet connected.

- (void)setCurrentCamera:(NSInteger)index;

- (void)fetchSSIDInfo;
- (void)onRefresh;

@end

@implementation WLBonjourCameraListManager

+ (nonnull instancetype)sharedManager {
    static dispatch_once_t pred;
    static WLBonjourCameraListManager *pDeviceManagerInstance = nil;
    dispatch_once(&pred, ^{
        pDeviceManagerInstance = [[[self class] alloc] init];
    });
    return pDeviceManagerInstance;
}

- (nullable WLCameraDevice*)currentCamera {
    return _currentDevice;
}

- (BOOL)hasDiscoveredAPDevice {
    if (_pZConfDevices.count != 0) {
        if ([WaylensCameraSDKConfig.current.defaultIPV4sUsingInCamera containsObject:[_pZConfDevices.firstObject getIPV4]]) {
            return YES;
        }
    }

    return NO;
}

- (id)init {
    self = [super init];
    if(self) {
        _pServices = [[NSMutableArray alloc]init];
        _pDelegateList = [[NSMutableArray alloc]init];
        _pZConfDevices = [[NSMutableArray alloc]init];
        _pConnectedDevices = [[NSMutableArray alloc]init];
        _pNetServieBrowserOld = nil;
        _pNetServieBrowserWaylens = nil;
        _currentWifi = [SSID currentSSID];
        _currentDevice = nil;
        _carrierName = [self getCarrierName];
    }
    return self;
}

- (BOOL)hasConnectedCameraWiFi {
    if (WaylensCameraSDKConfig.current.target == WaylensCameraSDKTargetToB) {
        return [self hasDiscoveredAPDevice];
    }
    else {
        if ([[SSID currentSSID] containsString:@"Waylens"]) {
            return YES;
        }
        else if ([self hasDiscoveredAPDevice]) {
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (NSString*)getCarrierName {
    // Setup the Network Info and create a CTCarrier object
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];

    // Get carrier name
    NSString *carrierName = [carrier carrierName];
    if (carrierName != nil) {
        NSLog(@"Carrier: %@", carrierName);
    }

    // Get mobile country code
    NSString *mcc = [carrier mobileCountryCode];
    if (mcc != nil) {
        NSLog(@"Mobile Country Code (MCC): %@", mcc);
    }

    // Get mobile network code
    NSString *mnc = [carrier mobileNetworkCode];
    if (mnc != nil) {
        NSLog(@"Mobile Network Code (MNC): %@", mnc);
    }
    return carrierName;
}

- (void)setCurrentCamera:(NSInteger)index {
    NSLog(@"setCurrentCamera: %d", (int)index);
    if (index >= 0 && index < [_pConnectedDevices count]) {
        _currentDevice = [_pConnectedDevices objectAtIndex:index];
    } else {
        _currentDevice = nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WLCurrentCameraChangeNotification object:self];
}

- (void)activate {
    if (_refreshTimer == nil) {
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onTimerRefresh) userInfo:nil repeats:YES];
        [_refreshTimer fire];
    }
    for (WLCameraDevice *device in _pConnectedDevices) {
        [device becomeActive];
    }
}

- (void)deactivate {
    [_refreshTimer invalidate];
    _refreshTimer = nil;
    for (WLCameraDevice *device in _pConnectedDevices) {
        [device resignActive];
    }
}

- (void)onTimerRefresh {
    if (_currentDevice == nil) {
        [self onRefresh];
    } else {
        if (_pServices.count > _pConnectedDevices.count) {
            NSLog(@"some detected Device is NOT connected! (%d--%d, %d)", (int)_pServices.count, (int)_pConnectedDevices.count, (int)_pZConfDevices.count);
            [self removeBounjour];
            [self registerBounjour];
        }
    }
}

- (void)onRefresh {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
        [self clearContext];
        [self setupContext];
    }];
}

// ---- wifi notify process
static void onNotifyCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSString* notifyName = (__bridge NSString*)name;
    if ([notifyName isEqualToString:[NSString stringWithCString:networkChangeName encoding:NSASCIIStringEncoding]]) {
        WLBonjourCameraListManager* obj = (__bridge WLBonjourCameraListManager*)observer;
        [obj fetchSSIDInfo];
    } else {
        NSLog(@"intercepted %@", notifyName);
    }
}

- (void)removeAllCameras {
    for(WLCameraDevice* device in _pZConfDevices) {
//        [[OneTouchUploadManager pInstance] removeCameraDevice:device];
        [[WLFirmwareUpgradeManager sharedManager] removeCamera:device];
        [device disconnect];
    }
    if (_currentDevice) {
        for(id<WLBonjourCameraListManagerDelegate> delegate in _pDelegateList) {
            [delegate bonjourCameraListManager:self didDisconnectCamera:_currentDevice];
        }
    }
    @synchronized(_pConnectedDevices) {
        [_pConnectedDevices removeAllObjects];
    }
    [_pZConfDevices removeAllObjects];
    if (_currentDevice) {
        [self setCurrentCamera:-1];
    }
}
- (void)clearContext {
    [self removeAllCameras];

    for (NSNetService* service in _pServices) {
        [service stop];
    }

    for(id<WLBonjourCameraListManagerDelegate> delegate in _pDelegateList) {
        [delegate bonjourCameraListManager:self didUpdateCameraList:_pConnectedDevices];
    }

    [self removeBounjour];
}

- (void)setupContext {
    [self registerBounjour];
}

- (void)removeBounjour {
    [_pServices removeAllObjects];
    if (_pNetServieBrowserOld) {
        [_pNetServieBrowserOld stop];
        _pNetServieBrowserOld = Nil;
    }
    if (_pNetServieBrowserWaylens) {
        [_pNetServieBrowserWaylens stop];
        _pNetServieBrowserWaylens = Nil;
    }
    CFStringRef aCFString;
    aCFString = CFStringCreateWithCString(NULL, networkChangeName, kCFStringEncodingASCII);
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                       (__bridge void*)self, // observer
                                       aCFString,//CFSTR(networkChangeName), // event name
                                       NULL);
    CFRelease(aCFString);
}
- (void)registerBounjour {
    CFStringRef aCFString;
    aCFString = CFStringCreateWithCString(NULL, networkChangeName, kCFStringEncodingASCII);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    (__bridge void*)self, // observer
                                    onNotifyCallback, // callback
                                    aCFString,//CFSTR(networkChangeName), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    CFRelease(aCFString);
    _pNetServieBrowserWaylens = [[NSNetServiceBrowser alloc]init];
    [_pNetServieBrowserWaylens setDelegate: self];
    [_pNetServieBrowserWaylens searchForServicesOfType:kWaylensServiceTypeEvcam inDomain:kInitialDomain];
    _pNetServieBrowserOld = [[NSNetServiceBrowser alloc]init];
    [_pNetServieBrowserOld setDelegate: self];
    [_pNetServieBrowserOld searchForServicesOfType:kWaylensServiceTypeCamClient inDomain:kInitialDomain];
}
- (void)onWifiChanged {
    [self clearContext];
    [self setupContext];
}

- (void)fetchSSIDInfo {
    NSString *ssid = [SSID currentSSID];
    NSString *previousSSID = _currentWifi;
    _currentWifi = ssid;
    if (previousSSID != nil && ![previousSSID isEqualToString:ssid]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for(id<WLBonjourCameraListManagerDelegate> delegate in self->_pDelegateList) {
                if ([delegate respondsToSelector:@selector(bonjourCameraListManager:didChangeNetwork:)]) {
                    [delegate bonjourCameraListManager:self didChangeNetwork:ssid];
                }
            }
            [self onWifiChanged];
        });
    }
}

- (nonnull NSArray<WLCameraDevice *> *)cameraList {
    return _pConnectedDevices;
}

- (nullable NSString *)currentWifi {
    return _currentWifi;
}

- (void)onDeviceConnected:(id)device {
    @synchronized(_pConnectedDevices) {
        if ([_pConnectedDevices containsObject:device]) {
        } else {
            if ([device isCamera]) {
                [_pConnectedDevices insertObject:device atIndex:0];
            } else {
                [_pConnectedDevices addObject:device];
            }

            if (_currentDevice == nil) {
                [self setCurrentCamera:0];
            } else {
                // TODO
                if ([[device getServiceType] isEqualToString:kWaylensServiceTypeEvcam]) {
                    if ([[_currentDevice getServiceType] isEqualToString:kWaylensServiceTypeCamClient]) {
                        [_currentDevice disconnect];
                        [self setCurrentCamera:0];
                    }
                }
            }

            [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
                if(self->_pDelegateList) {
                    for(id<WLBonjourCameraListManagerDelegate> delegate in self->_pDelegateList) {
                        [delegate bonjourCameraListManager:self didUpdateCameraList:self->_pConnectedDevices];
                    }
                }
            }];
//            [[OneTouchUploadManager pInstance] addCameraDevice:device];
        }
    }
}

- (void)onDeviceDisconnected:(id)device {
    @synchronized(_pConnectedDevices) {
        if ([_pConnectedDevices containsObject:device]) {
            [_pConnectedDevices removeObject:device];
            [[WLFirmwareUpgradeManager sharedManager] removeCamera:device];
            [[NSOperationQueue mainQueue]addOperationWithBlock:^(){
                if(self->_pDelegateList) {
                    for(id<WLBonjourCameraListManagerDelegate> delegate in self->_pDelegateList) {
                        [delegate bonjourCameraListManager:self didUpdateCameraList:self->_pConnectedDevices];
                    }
                }
            }];
            [_pZConfDevices removeObject:device];
//            [[OneTouchUploadManager pInstance] removeCameraDevice:device];
            [device disconnect];
            /*
             [(WLCameraDevice*)device setPConnectDele:self];
             [(WLCameraDevice*)device Connect];
             */
        }
    }

    if (device == _currentDevice) {
        for(id<WLBonjourCameraListManagerDelegate> delegate in _pDelegateList) {
            [delegate bonjourCameraListManager:self didDisconnectCamera:_currentDevice];
        }

        [self setCurrentCamera:0];

        for (NSNetService* service in _pServices) {
            if ([(WLCameraDevice*)device isViaService:service]) {
                [service stop];
                [_pServices removeObject:service];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_pNetServieBrowserOld searchForServicesOfType:kWaylensServiceTypeCamClient inDomain:kInitialDomain];
                    [self->_pNetServieBrowserWaylens searchForServicesOfType:kWaylensServiceTypeEvcam inDomain:kInitialDomain];
                });
                break;
            }
        }
    }
}

-(void)onDeviceUpdated:(id)dev{
    for(id<WLBonjourCameraListManagerDelegate> delegate in _pDelegateList) {
        if ([delegate respondsToSelector:@selector(bonjourCameraListManager:didUpdateCamera:)]) {
            [delegate bonjourCameraListManager:self didUpdateCamera:dev];
        }
    }
}

- (void)onDevice:(id)dev NameChanged:(NSString*)name {
    for(id<WLBonjourCameraListManagerDelegate> delegate in _pDelegateList) {
        if ([delegate respondsToSelector:@selector(bonjourCameraListManager:camera:didChangeName:)]) {
            [delegate bonjourCameraListManager:self camera:dev didChangeName:name];
        }
    }
}
- (void)onDevice:(id)dev recTime:(double)sec {
//    for(id<WLBonjourCameraListManagerDelegate> delegate in _pDelegateList) {
//        if ([delegate respondsToSelector:@selector(bonjourCameraListManager:camera:didChangeRecTime:)]) {
//            [delegate bonjourCameraListManager:self camera:dev didChangeRecTime:sec];
//        }
//    }
}
- (void)onDevice:(id)dev recErr:(NSError*)err {
    for(id<WLBonjourCameraListManagerDelegate> delegate in _pDelegateList) {
        if ([delegate respondsToSelector:@selector(bonjourCameraListManager:camera:didEncounterRecError:)]) {
            [delegate bonjourCameraListManager:self camera:dev didEncounterRecError:err];
        }
    }
}
- (void)onLiveMark:(BOOL)done {
    for(id<WLBonjourCameraListManagerDelegate> delegate in _pDelegateList) {
        if ([delegate respondsToSelector:@selector(bonjourCameraListManager:didLiveMark:)]) {
            [delegate bonjourCameraListManager:self didLiveMark:done];
        }
    }
}

- (void)addDelegate:(id<WLBonjourCameraListManagerDelegate> _Nonnull)delegate {
    if(_pDelegateList) {
        [_pDelegateList addObject:delegate];
    }
}

- (void)removeDelegate:(id<WLBonjourCameraListManagerDelegate> _Nonnull)delegate {
    if([_pDelegateList containsObject:delegate]) {
        [_pDelegateList removeObject:delegate];
    }
}

- (void)NewDevice:(NSArray*)saddr service:(NSNetService*)service {
    NSLog(@"-----NewDevice %@ %@", [service name], [service hostName]);

    BOOL iscamera = YES;

    if ([[service name] hasPrefix:@"Vidit Studio"] ||
        [[service name] hasPrefix:@"Waylens Studio"]) {
        iscamera = NO;
    }

    /*
    if (([[service name] isEqualToString:@"Waylens 360"]) ||
        ([[service name] isEqualToString:@"Horn360 Camera"])) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"com.hachi.debugOptions.enable360Demo"] == nil) {
            NSLog(@"Find Horn Camera, ignore~");
            return;
        }
    }
     */

    BOOL bConnectStudio = NO;
#ifdef ConnectStudio
    bConnectStudio = YES;
#endif
    if ((bConnectStudio == NO) && (iscamera == NO)) {
        return;
    }

    NSString* _ipv4 = nil;
    NSString* _ipv6 = nil;
    long _port = 10086;

    for (NSData* data in saddr) {
        struct sockaddr* addr = (struct sockaddr*)[data bytes];

        if(addr->sa_family == AF_INET) {
            struct sockaddr_in *p = (struct sockaddr_in *)addr;
            _ipv4 = [NSString stringWithCString:inet_ntoa(p->sin_addr) encoding:NSASCIIStringEncoding];
            _port = htons(p->sin_port);
            NSLog(@"new device: ipv4: %@, %lu", _ipv4, _port);
        }
        else if (addr->sa_family == AF_INET6) {
            char s_addr[64] = "";
            struct sockaddr_in6* p = (struct sockaddr_in6 *)[data bytes];
            inet_ntop(AF_INET6, &(p->sin6_addr), s_addr, 64);
            _ipv6 = [NSString stringWithCString:s_addr encoding:NSASCIIStringEncoding];
            _port = htons(p->sin6_port);
            NSLog(@"new device: ipv6: %@, %lu", _ipv6, _port);
        }
        else {
            NSLog(@"new device: sa_family: %@, %u", addr, addr->sa_family);
        }
    }
    
    if (_ipv4 == nil && _ipv6 == nil) {
        for (WLCameraDevice* dev in _pZConfDevices) {
            if ([dev isViaService:service]) {
                return;
            }
        }
        // this service is not used yet
        _ipv4 = WaylensCameraSDKConfig.current.defaultIPV4sUsingInCamera.firstObject;
        _ipv6 = @"2001:192:168:110::1";
        _port = 10086;
        NSLog(@"Try Connect %@", _ipv4);

        return;
    }
    
    WLCameraDevice *newdevice = [[WLCameraDevice alloc] initWithIPv4:_ipv4 IPv6:_ipv6 port:_port isCamera:iscamera];
    WLCameraDevice *sameDevice = nil;

    for (WLCameraDevice *device in _pZConfDevices) {
        if (([device.getIPV4 isEqualToString:_ipv4] || [device.getIPV6 isEqualToString:_ipv6]) && device.getPort == _port) {
            sameDevice = device;
            NSLog(@"Find same device");
            break;
        }
    }

    if (sameDevice && sameDevice.isConnected) {
        NSLog(@"Same device is already connected");
        // keep old device, ignore new device
    } else {
        // keep new device
        if (sameDevice) {
            // remove old device
            NSLog(@"remove same old devices");
            [_pZConfDevices removeObject:sameDevice];
            [sameDevice disconnect];
        }
        NSLog(@"Connect new device");
        [newdevice setService:service];
        [newdevice setDelegate:self];
        [newdevice connect];
        [_pZConfDevices addObject:newdevice];
    }
}

- (void)onServiceDisconnect:(NSNetService*)service moreComing:(BOOL)moreComing {
    NSLog(@"--onServiceDisconnect : %@", service);

#ifndef IgnoreBounjourServiceDisconnectEvent
    @synchronized(_pConnectedDevices) {
        for (WLCameraDevice* dev in _pConnectedDevices) {
            if([dev isViaService:service]) {
                [_pUpgradeMgr RemoveCamera:dev];
                [[OneTouchUploadManager pInstance] removeCameraDevice:dev];
                [dev disconnect];
                NSLog(@"--onServiceDisconnect 1: %@", dev);
                @synchronized(_pConnectedDevices) {
                    if ([_pConnectedDevices containsObject:dev]) {
                        [_pConnectedDevices removeObject:dev];
                    }
                }
                break;
            }
        }
//        if (_currentDevice) {
//            for(id<WLBonjourCameraListManagerDelegate> dele in _pDelegateList) {
////                [dele onDeviceDisconnected:_currentDevice];
//            }
//        }
        if ([_pConnectedDevices containsObject:_currentDevice] == NO) {
            //deleted
            [self setCurrentCamera:0 autoRefresh:YES];
        }
    }
    for (WLCameraDevice* dev in _pZConfDevices) {
        if([dev isViaService:service]) {
            NSLog(@"--onServiceDisconnect 2: %@", dev);
            //[_pUpgradeMgr RemoveCamera:device];
            if ([_pZConfDevices containsObject:dev]) {
                [_pZConfDevices removeObject:dev];
            }
            break;
        }
    }
#endif
    if ([_pServices containsObject:service]) {
        [service setDelegate:Nil];
        [_pServices removeObject:service];
    }
#ifndef IgnoreBounjourServiceDisconnectEvent
    if (!moreComing) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
            if(_pDelegateList) {
                for(id<WLBonjourCameraListManagerDelegate> dele in _pDelegateList) {
                    [dele onDeviceListUpdate:_pConnectedDevices];
                }
            }
        }];
    }
#endif
}

#pragma mark----NSNetServiceBrowserDelegate
- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {
    // If a service went away, stop resolving it if it's currently being resolved,
    // remove it from the list and update the table view if no more events are queued.
    //if (self.currentResolve && [service isEqual:self.currentResolve]) {
    //	[self stopCurrentResolve];
    //}
#ifndef IgnoreBounjourServiceDisconnectEvent
    [self onServiceDisconnect:service moreComing:moreComing];
#endif
    //[service setDelegate:Nil];
    // If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
    // When moreComing is set, we don't update the UI so that it doesn't 'flash'.
    if (!moreComing) {
        //[self sortAndUpdateUI];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
    // If a service came online, add it to the list and update the table view if no more events are queued.
//    NSLog(@"---didFindService %@", service.description);
    NSLog(@"---didFindService %@, moreComing: %d", service.description, moreComing);

    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        [self->_pServices addObject:service];
        [service setDelegate:self];
        [service resolveWithTimeout:0.0];
        // If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
        // When moreComing is set, we don't update the UI so that it doesn't 'flash'.
        if (!moreComing) {
            //[self sortAndUpdateUI];
        }
    }];
}
- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"netServiceWillResolve");
    [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
        [self NewDevice:nil service:sender];
    }];
}
- (void)netServiceDidStop:(NSNetService *)sender {
    NSLog(@"netServiceDidStop: %@", sender.description);
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"netServiceDidResolveAddress");
    NSArray* addrs = [sender addresses];
    //NSLog(@"sender: %@ %d", sender.name, (int)[addrs count]);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
//        for (NSData* addr in addrs) {
//            struct sockaddr* saddr = (struct sockaddr*)[addr bytes];
            [self NewDevice:addrs service:sender];
//        }
    }];
}
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"didNotResolve");
}

@end
