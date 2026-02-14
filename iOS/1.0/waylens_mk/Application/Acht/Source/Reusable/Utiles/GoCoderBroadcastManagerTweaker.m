//
//  GoCoderBroadcastManagerTweaker.m
//  Acht
//
//  Created by forkon on 2019/8/16.
//  Copyright © 2019 waylens. All rights reserved.
//

#import "GoCoderBroadcastManagerTweaker.h"
#import "RSSwizzle/RSSwizzle.h"
#import <AVFoundation/AVFoundation.h>

@implementation GoCoderBroadcastManagerTweaker

+ (void)tweak {

    static const void *key = &key;
    SEL selector = NSSelectorFromString(@"audioSessionStart");
    RSSwizzleInstanceMethod(NSClassFromString(@"GoCoderBroadcastManager"),
                            selector,
                            RSSWReturnType(void),
                            RSSWArguments(),
                            RSSWReplacement(
    {
        NSLog(@"Swizzle %@ audioSessionStart", self);
    }), RSSwizzleModeOncePerClassAndSuperclasses, key);

    static const void *key2 = &key2;
    SEL selector2 = NSSelectorFromString(@"audioSessionStop");
    RSSwizzleInstanceMethod(NSClassFromString(@"GoCoderBroadcastManager"),
                            selector2,
                            RSSWReturnType(void),
                            RSSWArguments(),
                            RSSWReplacement({
        NSLog(@"Swizzle %@ audioSessionStop", self);
    }), RSSwizzleModeOncePerClassAndSuperclasses, key2);

}

@end
