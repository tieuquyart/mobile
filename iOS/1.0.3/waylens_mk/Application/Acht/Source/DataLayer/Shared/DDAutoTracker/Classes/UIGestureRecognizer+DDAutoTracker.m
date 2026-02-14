//
//  UIGestureRecognizer+DDAutoTracker.m
//  Acht
//
//  Created by Chester Shen on 1/25/19.
//  Copyright © 2019 waylens. All rights reserved.
//

#import "UIGestureRecognizer+DDAutoTracker.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "DDAutoTrackerOperation.h"

@implementation UIGestureRecognizer (DDAutoTracker)
+ (void)startTracker {
    Method method = class_getInstanceMethod(UITapGestureRecognizer.class, @selector(touchesEnded:withEvent:));
    Method ddMethod = class_getInstanceMethod(self, @selector(dd_touchesEnded:withEvent:));
    method_exchangeImplementations(method, ddMethod);
}

- (void)dd_touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dd_touchesEnded:touches withEvent:event];
    if ([self isMemberOfClass:UITapGestureRecognizer.class]) {
        Ivar targetsIvar = class_getInstanceVariable([UIGestureRecognizer class], "_targets");
        id targetActionPairs = object_getIvar(self, targetsIvar);
        
        Class targetActionPairClass = NSClassFromString(@"UIGestureRecognizerTarget");
        Ivar targetIvar = class_getInstanceVariable(targetActionPairClass, "_target");
        Ivar actionIvar = class_getInstanceVariable(targetActionPairClass, "_action");
        
        for (id targetActionPair in targetActionPairs) {
            id target = object_getIvar(targetActionPair, targetIvar);
            SEL action = (__bridge void *)object_getIvar(targetActionPair, actionIvar);
            if (target && action) {
                NSString *eventId = [NSString stringWithFormat:@"%@/@%@",NSStringFromClass([target class]),NSStringFromSelector(action)];
                [[DDAutoTrackerOperation sharedInstance] sendTrackerData:eventId info:nil];
            }
        }
    }
}
@end
