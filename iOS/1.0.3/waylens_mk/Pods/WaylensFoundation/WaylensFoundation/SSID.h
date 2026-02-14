//
//  SSID.h
//  Hachi
//
//  Created by lzhu on 8/2/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSID : NSObject

+ (NSArray*) fetchSSIDs;
+ (NSString *)currentSSID;
@end

