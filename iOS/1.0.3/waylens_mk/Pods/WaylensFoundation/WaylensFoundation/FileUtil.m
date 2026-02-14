//
//  FileUtil.m
//  WaylensFoundation
//
//  Created by forkon on 2020/8/31.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import "FileUtil.h"
#import <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData 1024*8

@implementation FileUtil

//this MD5 dunction occupy less memory
CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,
                                      size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;

    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
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
        CC_MD5_CTX hashObject;
        CC_MD5_Init(&hashObject);

        // Make sure chunkSizeForReadingData is valid
        if (!chunkSizeForReadingData) {
            chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
        }

        // Feed the data to the hash object
        bool hasMoreData = true;
        while (hasMoreData) {
            uint8_t buffer[chunkSizeForReadingData];
            CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                      (UInt8 *)buffer,
                                                      (CFIndex)sizeof(buffer));
            if (readBytesCount == -1) break;
            if (readBytesCount == 0) {
                hasMoreData = false;
                continue;
            }
            CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
        }

        // Check if the read operation succeeded
        didSucceed = !hasMoreData;

        // Compute the hash digest
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &hashObject);

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
    return result;
}

+(NSString *)getfileMD5:(NSString *)path
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

@end
