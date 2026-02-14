//
//  UIViewController+DDAutoTracker.m
//  Acht
//
//  Created by Chester Shen on 1/24/19.
//  Copyright © 2019 waylens. All rights reserved.
//

#import "UIViewController+DDAutoTracker.h"
#import <objc/runtime.h>
#import "DDAutoTrackerOperation.h"

@implementation UIViewController (DDAutoTracker)
+ (void)startTracker {
    Method originalSelector = class_getInstanceMethod(self, @selector(viewDidAppear:));
    Method swizzledSelector = class_getInstanceMethod(self, @selector(dd_viewDidAppear:));
    method_exchangeImplementations(originalSelector, swizzledSelector);
}

- (void)dd_viewDidAppear:(BOOL)animated
{
    [self dd_viewDidAppear:animated];
    [self sendTrackerData];
    
}

- (void)sendTrackerData {
    NSString *eventId = [NSString stringWithFormat:@"%@/@viewDidAppear",NSStringFromClass([self class])];
    [[DDAutoTrackerOperation sharedInstance] sendTrackerData:eventId
                                                        info:nil];
}
@end
