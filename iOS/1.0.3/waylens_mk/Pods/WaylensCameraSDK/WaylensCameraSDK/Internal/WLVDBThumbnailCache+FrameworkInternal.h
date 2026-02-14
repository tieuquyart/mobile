//
//  WLVDBThumbnailCache+FrameworkInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/10/12.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>

static NSString* VDBThumbnailCachePathDictoryName = @"com.Waylens.Acht.VDBThumbnail.Cache";

@interface VDBThumbnailCacheItem : NSObject

@property (assign, nonatomic) long long clipID;
@property (assign, nonatomic) long long ptsInMS;
@property (assign, nonatomic) long durationInMS;

@property (strong, nonatomic) NSString *name;

+ (instancetype)itemWithClipID:(long long)clipID pts:(long long)pts duration:(long)duration file:(NSString *)name;

@end

@interface WLVDBThumbnailCache(FrameworkInternal)

@end

