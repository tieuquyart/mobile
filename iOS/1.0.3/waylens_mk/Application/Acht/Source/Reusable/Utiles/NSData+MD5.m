//
//  NSData+MD5.m
//  Acht
//
//  Created by forkon on 2018/11/20.
//  Copyright © 2018 waylens. All rights reserved.
//

#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (MD5)

-(NSString *)md5ASCIIEncrypt {
    const char *original_str = (const char *)[self bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)self.length, result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
