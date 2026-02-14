//
//  NSData+AES.h
//  MyLens
//
//  Created by gliu on 15/3/23.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSString;

@interface NSData (Encryption)

- (NSData *)AES128EncryptWithKey:(NSString *)key;
- (NSData *)AES128DecryptWithKey:(NSString *)key;


+ (BOOL)AES128EncryptWithKey:(NSString *)key input:(const char*)source length:(NSUInteger)len T0:(char*)outbuf outLength:(NSUInteger*)olen;
+ (BOOL)AES128DecryptWithKey:(NSString *)key input:(const char*)source length:(NSUInteger)len T0:(char*)outbuf outLength:(NSUInteger*)olen;

@end
