//
//  CDevice+FrameworkInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/27.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import "CDevice.h"

@interface CDevice(FrameworkInternal)
- (id)initWithIPv4:(NSString*)ipv4 IPv6:(NSString*)ipv6 port:(long)port;
@end
