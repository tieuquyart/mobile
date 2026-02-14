//
//  SRSUploader.h
//  Hachi
//
//  Created by gliu on 15/8/24.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#include "comm_protocol.h"

typedef void(^CRSProcessBlock)(int process, NSError* err);

@interface SRSUploader : NSObject

- (instancetype)initWithServerIP:(NSString*)ip port:(long)port privateKey:(NSString*)key;
- (BOOL)uploadData:(NSData*)data withType:(int)type ContentToken:(NSString*)token withBlock:(CRSProcessBlock)block;

@end
