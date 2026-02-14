//
//  TSCacheManager.h
//  Hachi
//
//  Created by gliu on 15/11/3.
//  Copyright © 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCacheManager : NSObject

+ (long long)cacheSize;

+ (void)clearCacheWithBlock:(void(^)(void))block;

/**
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    float size = [TSCacheManager CacheSize];
    NSLog(@"cache size: %f", size);
    [TSCacheManager clearCacheWithBlock:^{
        float size = [TSCacheManager CacheSize];
        NSLog(@"cache size: %f", size);
    }];
 });
 **/
@end
