//
//  UIBarButtonItem+DDAutoTracker.m
//  Acht
//
//  Created by Chester Shen on 1/25/19.
//  Copyright © 2019 waylens. All rights reserved.
//

#import "UIBarButtonItem+DDAutoTracker.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "DDAutoTrackerOperation.h"
#import "NSObject+DDAutoTracker.h"

@implementation UIBarButtonItem (DDAutoTracker)
+ (void)startTracker {
    Method endTrackingMethod = class_getInstanceMethod(self, @selector(endTrackingWithTouch:withEvent:));
    Method ddEndTrackingMethod = class_getInstanceMethod(self, @selector(dd_endTrackingWithTouch:withEvent:));
    method_exchangeImplementations(endTrackingMethod, ddEndTrackingMethod);
}

- (void)dd_endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self isKindOfClass:UIBarButtonItem.class]) {
        [self dd_endTrackingWithTouch:touch withEvent:event];
    }
    if (![self isMemberOfClass:[UIBarButtonItem class]]) {
        return;
    }
    if (self.target && self.action) {
        NSString *eventId = [NSString stringWithFormat:@"%@/@%@",NSStringFromClass([self.target class]), NSStringFromSelector(self.action)];
        NSDictionary *infoDictionary = [self.target ddInfoDictionary];
        [[DDAutoTrackerOperation sharedInstance] sendTrackerData:eventId
                                                            info:infoDictionary];
    }
}
@end
