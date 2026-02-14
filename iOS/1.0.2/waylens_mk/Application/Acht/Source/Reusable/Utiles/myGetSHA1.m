//
//  myGetSHA1.m
//  MyLens
//
//  Created by gliu on 15/3/24.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import "myGetSHA1.h"

#import <CommonCrypto/CommonDigest.h>

@implementation myGetSHA1

+(NSString*) getSHA1ValueFromData:(NSData*)data ToBuffer:(char*)buffer
{
    CC_SHA1_CTX hashObject;
    CC_SHA1_Init(&hashObject);
    CC_SHA1_Update(&hashObject,[data bytes],(CC_LONG)[data length]);
    // Compute the hash digest
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &hashObject);
    memcpy(buffer, digest, CC_SHA1_DIGEST_LENGTH);
     // Declare needed variables
     CFStringRef result = NULL;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)result;
}

#define FileHashDefaultChunkSizeForReadingData 1024*8

+(NSString*) getSHA1ValueFromFile:(NSString*)path ToBuffer:(char*)buffer
{
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;

    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)path,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);

    do{
        if (!fileURL) break;

        // Create and open the read stream
        readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                                (CFURLRef)fileURL);
        if (!readStream) break;
        bool didSucceed = (bool)CFReadStreamOpen(readStream);
        if (!didSucceed) break;

        // Initialize the hash object
        CC_SHA1_CTX hashObject;
        CC_SHA1_Init(&hashObject);
        // Feed the data to the hash object
        bool hasMoreData = true;
        while (hasMoreData) {
            uint8_t buffer[FileHashDefaultChunkSizeForReadingData];
            CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                      (UInt8 *)buffer,
                                                      (CFIndex)sizeof(buffer));
            if (readBytesCount == -1) break;
            if (readBytesCount == 0) {
                hasMoreData = false;
                continue;
            }
            CC_SHA1_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
        }
        // Check if the read operation succeeded
        didSucceed = !hasMoreData;
        // Compute the hash digest
        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1_Final(digest, &hashObject);


        memcpy(buffer, digest, CC_SHA1_DIGEST_LENGTH);

        // Abort if the read operation failed
        if (!didSucceed) break;
        // Compute the string result
        char hash[2 * sizeof(digest) + 1];
        for (size_t i = 0; i < sizeof(digest); ++i) {
            snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        }
        result = CFStringCreateWithCString(kCFAllocatorDefault,
                                           (const char *)hash,
                                           kCFStringEncodingUTF8);
    }while(0);

    //done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return (__bridge_transfer NSString *)result;
}
//
//+(NSString*) getSHA1ValueFromAsset:(ALAssetRepresentation*)assetRepresentation ToBuffer:(char*)buffer
//{
//    // Declare needed variables
//    CFStringRef result = NULL;
//    long long offset = 0;
//
//    do{
//        if (!assetRepresentation) break;
//
//        // Initialize the hash object
//        CC_SHA1_CTX hashObject;
//        CC_SHA1_Init(&hashObject);
//
//        // Feed the data to the hash object
//        bool hasMoreData = true;
//        while (hasMoreData) {
//            NSError *err;
//            uint8_t buffer[FileHashDefaultChunkSizeForReadingData];
//            CFIndex readBytesCount = (CFIndex)[assetRepresentation getBytes:buffer
//                                                                 fromOffset:offset
//                                                                     length:FileHashDefaultChunkSizeForReadingData
//                                                                      error:&err];
//            if ([err code] != noErr) {
//                break;
//            }
//            offset += FileHashDefaultChunkSizeForReadingData;
//            if (readBytesCount <= 0) break;
//            CC_SHA1_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
//            if (readBytesCount < FileHashDefaultChunkSizeForReadingData) break;
//        }
//
//        // Compute the hash digest
//        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
//        CC_SHA1_Final(digest, &hashObject);
//
//        memcpy(buffer, digest, CC_SHA1_DIGEST_LENGTH);
//
//        // Compute the string result
//        char hash[2 * sizeof(digest) + 1];
//        for (size_t i = 0; i < sizeof(digest); ++i) {
//            snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
//        }
//        result = CFStringCreateWithCString(kCFAllocatorDefault,
//                                           (const char *)hash,
//                                           kCFStringEncodingUTF8);
//    }while(0);
//    return (__bridge_transfer NSString *)result;
//}
@end
