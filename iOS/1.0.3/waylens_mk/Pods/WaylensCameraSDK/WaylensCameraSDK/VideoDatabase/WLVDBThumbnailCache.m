//
//  WLVDBThumbnailCache.m
//  Hachi
//
//  Created by gliu on 16/4/11.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import "WLVDBThumbnailCache.h"
#import "WLVDBThumbnailCache+FrameworkInternal.h"
#import <CommonCrypto/CommonDigest.h>

@implementation VDBThumbnailCacheItem
+ (instancetype)itemWithClipID:(long long)clipID pts:(long long)pts duration:(long)duration file:(NSString*)name {
    VDBThumbnailCacheItem *item = [[VDBThumbnailCacheItem alloc] init];
    if (item) {
        item.clipID = clipID;
        item.ptsInMS = pts;
        item.durationInMS = duration;
        item.name = name;
    }
    return item;
}

@end

@interface WLVDBThumbnailCache () {
    NSString*       cachePath;
    NSMutableArray* list; //path, pts, duration, clipID
    NSLock *lock;
}

@end

@implementation WLVDBThumbnailCache

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static WLVDBThumbnailCache *pInstance = nil;
    dispatch_once(&pred, ^{
        pInstance = [[[self class] alloc] init];
    });
    return pInstance;
}

- (void)cleanCache {
    [lock lock];
    [list removeAllObjects];
    [self createCacheDictIfNecessary];
    [lock unlock];
}

- (void)addThumbnail:(NSData*)image withTimestamp:(long long)PTSMS durationInMS:(long)duration clipID:(long)clipID {
    [lock lock];
    if (list.count >= self.cacheThumbnailNumber) {
        [self removeFileOfItem:list[0]];
        [list removeObjectAtIndex:0];
    }
    VDBThumbnailCacheItem* item = [VDBThumbnailCacheItem itemWithClipID:clipID pts:PTSMS duration:duration ? : 1000 file:nil];
    if ([self saveData:image ForItem:item]) {
        [list addObject:item];
    }
    [lock unlock];
}

- (NSData *)getThumbnailAtTimestamp:(long long)ms inClip:(long)clipID ptsInMS:(long long *)pts durationInMS:(long *)duration {
    // TODO: optimize cache hit query
    [lock lock];
    for (VDBThumbnailCacheItem* item in list) {
        if (item.clipID == clipID) {
            if ((item.ptsInMS <= ms) && (item.ptsInMS + item.durationInMS > ms)) {
                *pts = item.ptsInMS;
                *duration = item.durationInMS;
                [lock unlock];
                return [self readDataForItem:item];
            }
        }
    }
    [lock unlock];
    return nil;
}
- (void)setCacheThumbnailNumber:(NSUInteger)cacheThumbnailNum {
    [lock lock];
    if (_cacheThumbnailNumber != cacheThumbnailNum) {
        if (cacheThumbnailNum < 100) {
            _cacheThumbnailNumber = 100;
        } else if (cacheThumbnailNum >= 5000) {
            _cacheThumbnailNumber = 5000;
        } else {
            _cacheThumbnailNumber = cacheThumbnailNum;
        }
        while (list.count > _cacheThumbnailNumber) {
            [self removeFileOfItem:list[0]];
            [list removeObjectAtIndex:0];
        }
    }
    [lock unlock];
}

#pragma mark -- private
- (id)init {
    self = [super init];
    if (self) {
        lock = [[NSLock alloc] init];
        _cacheThumbnailNumber = 1000;
        list = [[NSMutableArray alloc] init];
        [self createCacheDictIfNecessary];
        [self loadThumbnailListFromDisk];
    }
    return self;
}
- (void)createCacheDictIfNecessary {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    cachePath = [paths[0] stringByAppendingPathComponent:VDBThumbnailCachePathDictoryName];
    BOOL isdict = NO;
    BOOL bFind = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isdict];
    if (!bFind || !isdict) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}
- (void)loadThumbnailListFromDisk {
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
    [lock lock];
    for (NSString* file in files) {
        long clipID = -1;
        long long pts = -1;
        long duration = -1;
        if([self parseFileName:file ClipID:&clipID PTSinMS:&pts DurationinMS:&duration]) {
            [list addObject:[VDBThumbnailCacheItem itemWithClipID:clipID pts:pts duration:duration file:file]];
        }
    }
    [lock unlock];
}
- (NSString*)getCachFileNameIfExist:(long long)ms clip:(long)clipID {
    NSString* path = nil;

    return path;
}
- (NSString*)compileCachFileNameWithItem:(VDBThumbnailCacheItem*)item {
    NSString* path = [NSString stringWithFormat:@"%08llx-%08llx-%04lx", item.clipID, item.ptsInMS, item.durationInMS];
    return path;
}
- (BOOL)parseFileName:(NSString*)file ClipID:(long*)clipid PTSinMS:(long long*)pts DurationinMS:(long*)duration {
    NSRange range = [file rangeOfString:@"-"];
    unsigned long long longValue;
    if (range.length > 0) {
        NSScanner* scanner = [NSScanner scannerWithString: [file substringToIndex:range.location]];
        [scanner scanHexLongLong: &longValue];
        *clipid = (long)longValue;
    } else {
        return NO;
    }
    NSRange range2 = [[file substringFromIndex:range.location + 1] rangeOfString:@"-"];
    if (range2.length > 0) {
        if (range2.location - 1 > file.length) {
            //
        }
        NSScanner* scanner = [NSScanner scannerWithString: [file substringWithRange:NSMakeRange(range.location + 1, range2.location)]];
        [scanner scanHexLongLong: &longValue];
        *pts = longValue;
        longValue = 0;
        scanner = [NSScanner scannerWithString:[[file substringFromIndex:range.location + 1] substringFromIndex:range2.location + 1]];
        [scanner scanHexLongLong: &longValue];
        *duration = (long)longValue;
    } else {
        return NO;
    }
    return (*clipid != -1) && (*pts != -1) && (*duration != -1);
}
- (BOOL)saveData:(NSData*)img ForItem:(VDBThumbnailCacheItem*)item {
    NSString* name = [self compileCachFileNameWithItem:item];
    item.name = name;
    if (name) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[cachePath stringByAppendingPathComponent:name]]) {
            [[NSFileManager defaultManager]removeItemAtPath:[cachePath stringByAppendingPathComponent:name] error:nil];
        }
        return [[NSFileManager defaultManager] createFileAtPath:[cachePath stringByAppendingPathComponent:name] contents:img attributes:nil];
    }
    return NO;
}
- (NSData*)readDataForItem:(VDBThumbnailCacheItem*)item {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[cachePath stringByAppendingPathComponent:item.name]]) {
        return [[NSFileManager defaultManager] contentsAtPath:[cachePath stringByAppendingPathComponent:item.name]];
    }
    return nil;
}
- (void)removeFileOfItem:(VDBThumbnailCacheItem*)item {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[cachePath stringByAppendingPathComponent:item.name]]) {
        [[NSFileManager defaultManager]removeItemAtPath:[cachePath stringByAppendingPathComponent:item.name] error:nil];
    }
}
@end
