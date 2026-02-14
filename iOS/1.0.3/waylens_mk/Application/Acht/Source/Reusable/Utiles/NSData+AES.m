//
//  NSData+AES.m
//  MyLens
//
//  Created by gliu on 15/3/23.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import "NSData+AES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (Encryption)

- (NSData *)AES128EncryptWithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData* ret = [[NSData alloc] initWithBytes:buffer length:numBytesEncrypted];
        free(buffer);
        return ret;
    }
    free(buffer);
    return nil;
}

- (NSData *)AES128DecryptWithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          /*kCCOptionPKCS7Padding | */kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData* ret = [[NSData alloc] initWithBytes:buffer length:numBytesDecrypted];
        free(buffer);
        return ret;
    }
    free(buffer);
    return nil;
}


+ (BOOL)AES128EncryptWithKey:(NSString *)key input:(const char*)source length:(NSUInteger)len T0:(char*)outbuf outLength:(NSUInteger*)olen {
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = len;
    *olen = dataLength + kCCBlockSizeAES128;
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          source, dataLength,
                                          outbuf, *olen,
                                          &numBytesEncrypted);
    return (cryptStatus == kCCSuccess);
}
+ (BOOL)AES128DecryptWithKey:(NSString *)key input:(const char*)source length:(NSUInteger)len T0:(char*)outbuf outLength:(NSUInteger*)olen {
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = len;
    *olen = dataLength + kCCBlockSizeAES128;
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          /*kCCOptionPKCS7Padding | */kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          source, dataLength,
                                          outbuf, *olen,
                                          &numBytesDecrypted);
    return (cryptStatus == kCCSuccess);
}
@end
