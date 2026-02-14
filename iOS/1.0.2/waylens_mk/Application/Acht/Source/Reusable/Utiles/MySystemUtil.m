//
//  MySystemUtil.m
//  Vidit
//
//  Created by gliu on 14-9-22.
//  Copyright (c) 2014年 Transee Design. All rights reserved.
//
//#import <Security/Security.h>

#import "MySystemUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <zlib.h>
#include "sys/stat.h"
#import <arpa/inet.h>
#import <netdb.h>

#include "sys/stat.h"

#define IOS7 [[[UIDevice currentDevice] systemVersion]floatValue]>=7
#ifndef __IPHONE_8_0
#define IOS8 0
#else
#define IOS8 [[[UIDevice currentDevice] systemVersion]floatValue]>=8
#endif

#define FileHashDefaultChunkSizeForReadingData 1024*8

@implementation MySystemUtil
+(CGSize)ScreenSize
{
    CGSize size;
    if (IOS8) {
        return [[UIScreen mainScreen ] bounds ].size;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(( orientation == UIInterfaceOrientationPortrait)||(orientation == UIInterfaceOrientationPortraitUpsideDown)) {
        size.width = [[UIScreen mainScreen ] bounds ].size.width;
        size.height = [[UIScreen mainScreen ] bounds ].size.height;
    } else {
        size.width = [[ UIScreen mainScreen ] bounds ].size.height;
        size.height = [[ UIScreen mainScreen ] bounds ].size.width;
    }
    return size;
}
+(CGFloat)ScreenWidth
{
    if (IOS8) {
        return [[UIScreen mainScreen ] bounds ].size.width;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(( orientation == UIInterfaceOrientationPortrait)||(orientation == UIInterfaceOrientationPortraitUpsideDown)) {
        return [[UIScreen mainScreen ] bounds ].size.width;
    } else {
        return [[UIScreen mainScreen ] bounds ].size.height;
    }
}
+(CGFloat)ScreenHeight
{
    if (IOS8) {
        return [[UIScreen mainScreen ] bounds ].size.height;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(( orientation == UIInterfaceOrientationPortrait)||(orientation == UIInterfaceOrientationPortraitUpsideDown)) {
        return [[UIScreen mainScreen ] bounds ].size.height;
    } else {
        return [[UIScreen mainScreen ] bounds ].size.width;
    }
}

+(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }

    return totalFreeSpace;
}

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

//+(unsigned long )GetCRCFrom:(NSData*)data
//{
//    unsigned long crc = crc32(0L, Z_NULL, 0);
//    crc = crc32(crc, [data bytes], (uInt)[data length]);
//    return crc;
//}

+(unsigned long long) fileSizeAtPath:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}

+(NSString*)getfileMD5:(NSString*)path
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}
+(NSString*) getIPAddressForHostString:(NSString*)host
{
    struct hostent *hostentry;
    hostentry = gethostbyname([host UTF8String]);
    char * ipbuf;
    ipbuf = inet_ntoa(*((struct in_addr *)hostentry->h_addr_list[0]));
    return [NSString stringWithUTF8String:ipbuf];
}

+(NSString*) timeStringFromTimeInteval:(NSTimeInterval)time {
    int intduration = floor(time + 0.5);
    if (time >= 3600) {
        return [NSString stringWithFormat:@"%d:%02d:%02d",
                     intduration/3600,
                     (intduration-(intduration/3600)*3600)/60,
                     intduration - (intduration/60)*60];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d",
                     (intduration-(intduration/3600)*3600)/60,
                     intduration - (intduration/60)*60];
    }
}
+ (BOOL)isSameDay:(double)time with:(double)basetime {
    BOOL bSame = NO;
    if (time - basetime >= 24 * 3600.0) {
        return bSame;
    }
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: [NSDate date]];
    NSDate* new = [NSDate dateWithTimeIntervalSince1970:time - interval];
    NSDateComponents* newcomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:new];
    NSDate* base = [NSDate dateWithTimeIntervalSince1970:basetime - interval];
    NSDateComponents* basecomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:base];
    if ((newcomponents.year == basecomponents.year) &&
        (newcomponents.month == basecomponents.month) &&
        (newcomponents.day == basecomponents.day)) {
        bSame = YES;
    }
    return bSame;
}
@end


@implementation UIImage (scale)

-(UIImage*)scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);

    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];

    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    // 使当前的context出堆栈
    UIGraphicsEndImageContext();

    // 返回新的改变大小后的图片
    return scaledImage;
}
@end

@interface WeakContainer : NSObject
@property (weak, nonatomic) id value;
-(instancetype)initWithValue:(id)value;
@end

@implementation WeakContainer
-(instancetype)initWithValue:(id)value {
    self = [super init];
    _value = value;
    return self;
}
@end


@implementation myIdleTimerManager

+(myIdleTimerManager*) Instance {
    static dispatch_once_t pred;
    static myIdleTimerManager *idleTimerManager = nil;
    dispatch_once(&pred, ^{
        idleTimerManager = [[[self class] alloc] init];
    });
    return idleTimerManager;
}

-(id) init
{
    self = [super init];
    if (self) {
        _pTimerHandlers = [[NSMutableArray alloc] init];
        _bLockerDisabled = NO;
        _bRunning = YES;
    }
    return self;
}

-(NSInteger)findHandler:(id)handler {
    for (NSInteger i=0; i< _pTimerHandlers.count; i++) {
        WeakContainer *container = _pTimerHandlers[i];
        if (container.value == handler) {
            return i;
        }
    }
    return -1;
}

-(void) myIdleTimerAdd:(id)handler
{
    if (!_bRunning || [self findHandler:handler] >= 0) {
        return;
    }
    WeakContainer *container = [[WeakContainer alloc] initWithValue:handler];
    [_pTimerHandlers addObject:container];
    if (_bLockerDisabled == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        });
        _bLockerDisabled = YES;
        NSLog(@"##setIdleTimerDisabled:YES##");
    }
}

-(void) myIdleTimerRemove:(id)handler
{
    NSInteger index = [self findHandler:handler];
    if (index >= 0) {
        [_pTimerHandlers removeObjectAtIndex:index];
        if ([_pTimerHandlers count] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            });
            _bLockerDisabled = NO;
            NSLog(@"##setIdleTimerDisabled:NO##");
        }
    }
}

-(void) myIdleTimerRun:(BOOL)brun
{
    if (brun) {
        _bRunning = YES;
    } else {
        _bRunning = NO;
        NSArray *array = [NSArray arrayWithArray:_pTimerHandlers];
        for (id handler in array) {
            [self myIdleTimerRemove:handler];
        }
    }
}

@end
