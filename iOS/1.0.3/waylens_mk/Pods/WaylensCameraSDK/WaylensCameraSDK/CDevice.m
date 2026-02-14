//
//  CDevice.m
//  Hachi
//
//  Created by gliu on 16/3/24.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import "CDevice.h"
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation CDevice

- (id)initWithIPv4:(NSString*)ipv4 IPv6:(NSString*)ipv6 port:(long)port {
    self = [super init];
    if(self) {
        _ipv4 = ipv4;
        _port = port;
        _ipv6 = ipv6;
    }
    return self;
}

- (void)setService:(NSNetService*)service {
    _pNetService = service;
}
- (BOOL)isViaService:(NSNetService*)service {
    return  [_pNetService isEqual:service];
}
- (NSUInteger)getPort {
    return _port;
}
- (NSString*)getIPV4 {
    return _ipv4;
}
- (NSString*)getIPV6 {
    return _ipv6;
}

- (NSString*)getServiceName {
    return [_pNetService name];
}

- (NSString*)getServiceType {
    return [_pNetService type];
}

- (NSString*)getHostName {
    if (!_hostname) {
        NSString *host = [_pNetService hostName];
        if (host) {
            NSRange range = [host rangeOfString:@".local." options:NSBackwardsSearch];
            if (range.length != 0) {
                _hostname = [host substringToIndex:range.location];
            } else {
                _hostname = host;
            }
        }
    }
    return _hostname;
}

@end
