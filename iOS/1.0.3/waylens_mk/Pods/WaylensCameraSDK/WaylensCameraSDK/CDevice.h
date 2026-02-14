//
//  CDevice.h
//  Hachi
//
//  Created by gliu on 16/3/24.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CDeviceDelegate <NSObject>
#pragma mark - connection
- (void)onDeviceConnected:(id)dev;
- (void)onDeviceDisconnected:(id)dev;
@end

@interface CDevice : NSObject {
    NSString*           _ipv4;
    NSUInteger          _port;
    NSString*           _ipv6;
    NSNetService*       _pNetService;//camera or studio
    NSString*           _hostname;
}

- (void)setService:(NSNetService*)service;

- (BOOL)isViaService:(NSNetService*)service;
- (NSUInteger)getPort;
- (NSString*)getIPV4;
- (NSString*)getIPV6;
- (NSString*)getServiceName;
- (NSString*)getServiceType;
- (NSString*)getHostName;

@end
