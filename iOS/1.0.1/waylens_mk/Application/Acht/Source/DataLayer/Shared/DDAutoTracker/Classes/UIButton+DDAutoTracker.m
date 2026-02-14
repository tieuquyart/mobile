//
//  UIButton+DDAutoTracker.m
//  DDAutoTracker
//
//  Created by 王海亮 on 2017/12/18.
//

#import "UIButton+DDAutoTracker.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "DDAutoTrackerOperation.h"
#import "NSObject+DDAutoTracker.h"

@implementation UIButton (DDAutoTracker)

+ (void)startTracker {
    Method endTrackingMethod = class_getInstanceMethod(self, @selector(endTrackingWithTouch:withEvent:));
    Method ddEndTrackingMethod = class_getInstanceMethod(self, @selector(dd_endTrackingWithTouch:withEvent:));
    method_exchangeImplementations(endTrackingMethod, ddEndTrackingMethod);
}

- (void)dd_endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (![self isKindOfClass:[UIButton class]]) {
        return;
    }
    [self dd_endTrackingWithTouch:touch withEvent:event];
    NSArray *targets = [self.allTargets allObjects];
    if (targets.count > 0) {
        NSArray *actions = [self actionsForTarget:[targets firstObject] forControlEvent:UIControlEventTouchUpInside];
        if (actions.count > 0 &&
            [[actions firstObject] length] > 0) {
            
            NSString *eventId = [NSString stringWithFormat:@"%@/@%@",NSStringFromClass([[targets firstObject] class]),[actions firstObject]];
            NSDictionary *infoDictionary = [[targets firstObject] ddInfoDictionary];
            [[DDAutoTrackerOperation sharedInstance] sendTrackerData:eventId
                                                                info:infoDictionary];
        }
    }
}

@end

@implementation UIControl (DDAutoTracker)
+ (void)startTracker {
    Method method = class_getInstanceMethod(self, @selector(touchesEnded:withEvent:));
    Method ddMethod = class_getInstanceMethod(self, @selector(dd_touchesEnded:withEvent:));
    method_exchangeImplementations(method, ddMethod);
}

- (void)dd_touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dd_touchesEnded:touches withEvent:event];
    id target = self.allTargets.allObjects.firstObject;
    if (target != nil) {
        NSArray *actions = [self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
        NSString *action = actions.firstObject;
        if (action.length > 0) {
            if ([NSStringFromClass([target class]) isEqualToString:@"_UIButtonBarTargetAction"]) {
                
            }
            NSString *eventId = [NSString stringWithFormat:@"%@/@%@",NSStringFromClass([target class]), action];
            NSDictionary *infoDictionary = [target ddInfoDictionary];
            [[DDAutoTrackerOperation sharedInstance] sendTrackerData:eventId
                                                                info:infoDictionary];
        }
    }
}
@end

@implementation UIApplication (DDAutoTracker)
+ (void)startTracker {
    Method method = class_getInstanceMethod(self, @selector(sendAction:to:from:forEvent:));
    Method ddMethod = class_getInstanceMethod(self, @selector(dd_sendAction:to:from:forEvent:));
    method_exchangeImplementations(method, ddMethod);
}

- (BOOL)dd_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event {
    BOOL ret = [self dd_sendAction:action to:target from:sender forEvent:event];
    NSString *eventId = [NSString stringWithFormat:@"%@/@%@",NSStringFromClass([target class]), NSStringFromSelector(action)];
    NSDictionary *infoDictionary = [sender UIControlInfoDictionary];
    [[DDAutoTrackerOperation sharedInstance] sendTrackerData:eventId
                                                        info:infoDictionary];
    return ret;
}

@end

