//
//  NSData+AES.h
//  Hachi
//
//  Created by gliu on 15/3/23.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;

@interface NSData (OBD)

- (NSString*)getOBDVIN;

- (float)getOBDSpeed;
- (float)getOBDRPM;
- (float)getOBDThrottle;
- (float)getOBDPsiWithPressure:(int)kPa;
- (float)getOBDBarometricPressureWithPressure:(int)kPa;

@end
