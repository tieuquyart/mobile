//
//  UIView+SubViews.m
//  TuTu
//
//  Created by lzhu on 12/30/15.
//  Copyright © 2015 Transee. All rights reserved.
//

#import "UIView+SubViews.h"
#import "NSMutableArray+Queue.h"
#import "NSMutableArray+Stack.h"

@implementation UIView (SubViews)

- (void) traverseAllSubViewsRecursively:(BOOL)recursive {
    NSLog(@"0 : %@ object tree : \t %@", [self class], NSStringFromCGRect(self.frame));
    [self traverseAllSubViewsAtLevel:1 recursively:YES];
}


- (void) traverseAllSubViewsAtLevel:(NSInteger)level recursively:(BOOL)recursive {
    for(UIView *subView in self.subviews) {
        NSMutableString *mstr = [NSMutableString stringWithFormat:@"%@ : ", @(level)];
        for(NSInteger idx = 0; idx < level; ++idx) {
            [mstr appendString:@"\t"];
        }
        [mstr appendFormat:@"%@", NSStringFromClass([subView class])];
        [mstr appendFormat:@" \t%@", NSStringFromCGRect(self.frame)];
        NSLog(@"%@", mstr);
        if(recursive) {
            [subView traverseAllSubViewsAtLevel:level+1 recursively:recursive];
        }
    }
}

- (UIView*) subViewWithClass:(NSString*)className recursively:(BOOL)recursive {
    NSMutableArray *queue = [NSMutableArray queue];
    [queue pushObjectsFromArray:self.subviews];
    while (!queue.empty) {
        UIView *view = [queue frontObject];
        [queue dequeueObject];
        if([view isKindOfClass:NSClassFromString(className)]) {
            return view;
        } else if(recursive) {
            [queue enqueueObjectsFromArray:view.subviews];
        }
    }
    return nil;
}

- (NSArray*) subViewsWithClass:(NSString*)className recursively:(BOOL)recursive {
    NSMutableArray *queue = [NSMutableArray queue];
    NSMutableArray *results = [NSMutableArray array];
    [queue pushObjectsFromArray:self.subviews];
    while (!queue.empty) {
        UIView *view = [queue frontObject];
        [queue dequeueObject];
        if([view isKindOfClass:NSClassFromString(className)]) {
            [results addObject:view];
        }
        if(recursive) {
            [queue enqueueObjectsFromArray:view.subviews];
        }
    }
    return results;
}

- (NSLayoutConstraint*) layoutConstraintWithIdentifier:(NSString*)identifier {
    NSAssert(identifier && ![@"" isEqualToString:identifier], @"identifier can not be empty");
    for (NSLayoutConstraint *layout in self.constraints) {
        if(layout.identifier && [layout.identifier isEqualToString:identifier]) {
            return layout;
        }
    }
    return nil;
}

- (void) setCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor*)color {
    self.layer.cornerRadius = radius;
    self.layer.borderWidth = width;
    if(width != 0.0f && color != nil)
        self.layer.borderColor = color.CGColor;
    self.clipsToBounds = YES;
}

- (void) recursivelyClearAllGestures:(BOOL)recursive {
    NSMutableArray *stack = [NSMutableArray stack];
    [stack pushObject:self];
    while (!stack.empty) {
        UIView *view = [stack topObject];
        [stack popObject];
        NSArray *gestures = [view.gestureRecognizers copy];
        for (id gesture in gestures) {
            [view removeGestureRecognizer:gesture];
        }
        if(recursive && view.subviews.count != 0) {
            [stack pushObjectsFromArray:view.subviews];
        }
    }
}

- (void) setAllSubViewToColor:(UIColor*)color {
    NSMutableArray *queue = [NSMutableArray queue];
    self.backgroundColor = color;
    [queue pushObjectsFromArray:self.subviews];
    while (!queue.empty) {
        UIView *view = [queue frontObject];
        [queue dequeueObject];
        view.backgroundColor = color;
        [queue enqueueObjectsFromArray:view.subviews];
    }
}

- (UIButton*) buttonWithTitle:(NSString*)title {
    NSMutableArray *queue = [NSMutableArray queue];
    [queue pushObjectsFromArray:self.subviews];
    while (!queue.empty) {
        UIView *view = [queue frontObject];
        [queue dequeueObject];
        if([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)view;
            if([btn.titleLabel.text isEqualToString:title]) {
                return btn;
            }
        }
        [queue enqueueObjectsFromArray:view.subviews];
    }
    return nil;
}

@end


@implementation UIWindow (SubViews)

- (void) showStatusBar {
    if(![[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        return;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat max = MAX(size.width, size.height);
    if(max < 568) {
        return;
    }
    CGRect frame = self.frame;
    frame.origin.y += 20;
    frame.size.height -= 20;
    self.frame = frame;
    self.clipsToBounds = YES;
    UIView *layoutView = [self subViewWithClass:@"UILayoutContainerView" recursively:YES];
    if(layoutView) {
        layoutView.frame = CGRectMake(0, -20, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) + 20);
    }
}

@end
