//
//  WLVDBThumbnailCache.h
//  Hachi
//
//  Created by gliu on 16/4/11.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLVDBThumbnailCache: NSObject

/*
 Max number of thumbnails in cache. Default value is 1000, use about 60~70MB storage (60~70KB per thumbnail in average).
 The valid number range is [100, 5000].
 */
@property (assign, nonatomic) NSUInteger cacheThumbnailNumber;

+ (instancetype)sharedInstance;

/*
 Call this API when clean all the files directly by other modules.
 After this API is called, the index of cache files will be released.
 */
- (void)cleanCache;

- (void)addThumbnail:(NSData *)image withTimestamp:(long long)PTSMS durationInMS:(long)duration clipID:(long)clipID;

/*
 Find thumbnail in cache. NSData is retuned if pic is found. return nil if found nothing.
 */
- (NSData *)getThumbnailAtTimestamp:(long long)ms inClip:(long)clipID ptsInMS:(long long *)pts durationInMS:(long *)duration;

@end
