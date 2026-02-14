//
//  TSCacheManager.m
//  Hachi
//
//  Created by gliu on 15/11/3.
//  Copyright © 2015年 Transee. All rights reserved.
//

#import "TSCacheManager.h"
#import <WaylensCameraSDK/WaylensCameraSDK.h>

@implementation TSCacheManager

+ (long long)fileSizeAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size;
    }
    return 0;
}

+ (long long)cacheSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    long long folderSize = 0;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path = paths[0];
//    NSArray * files = [fileManager subpathsAtPath:path];
//    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            folderSize += [TSCacheManager fileSizeAtPath:absolutePath];
        }
    }

    path = NSTemporaryDirectory();
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            folderSize += [TSCacheManager fileSizeAtPath:absolutePath];
        }
    }
//    path = [TSVDBRawDataCache shareInstance].basePath;
//    if ([fileManager fileExistsAtPath:path]) {
//        NSArray *childerFiles=[fileManager subpathsAtPath:path];
//        for (NSString *fileName in childerFiles) {
//            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
//            folderSize += [TSCacheManager fileSizeAtPath:absolutePath];
//        }
//    }
    path = [WLFirmwareUpgradeManager sharedManager].basePath;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            folderSize += [TSCacheManager fileSizeAtPath:absolutePath];
        }
    }
    return folderSize;
}
+ (void)clearCacheWithBlock:(void(^)(void))block {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path = paths[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray * files = [fileManager subpathsAtPath:path];
    for ( NSString * p in files) {
        NSString * file = [path stringByAppendingPathComponent:p];
        if ([fileManager fileExistsAtPath:file]) {
            [fileManager removeItemAtPath:file error:nil];
        }
    }
    [[WLVDBThumbnailCache sharedInstance] cleanCache];
//    [fileManager removeItemAtPath:path error:nil];
    path = NSTemporaryDirectory();
//    if ([fileManager fileExistsAtPath:path]) {
//        NSArray *childerFiles = [fileManager subpathsOfDirectoryAtPath:path error:nil];
//        for (NSString *fileName in childerFiles) {
//            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
//            [fileManager removeItemAtPath:absolutePath error:nil];
//        }
//    }
    [fileManager removeItemAtPath:path error:nil];
//    for (NSString* cam in [[TSVDBRawDataCache shareInstance] getSavedCamerasList]) {
//        [[TSVDBRawDataCache shareInstance] deleteAllDataForCamera:cam];
//    }
    [[WLFirmwareUpgradeManager sharedManager] resetLocalFiles];
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}
@end
