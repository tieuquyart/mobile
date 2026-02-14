//
//  NSString+HMAC.h
//  Hachi
//
//  Created by Waylens Administrator on 8/22/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(HMAC)
+ (NSString *)hmac:(NSString *)plaintext withKey:(NSString *)key;
@end
