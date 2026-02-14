//
//  UIView+SubViews.h
//  TuTu
//
//  Created by lzhu on 12/30/15.
//  Copyright © 2015 Transee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SubViews)

//打印出当前VIEW的所有subView， 用于分析VIEW及其子类的组合结构
- (void) traverseAllSubViewsRecursively:(BOOL)recursive;

- (UIView*) subViewWithClass:(NSString*)className recursively:(BOOL)recursive;  //first found or nil
- (NSArray*) subViewsWithClass:(NSString*)className recursively:(BOOL)recursive;//an array with views or an empty array

- (NSLayoutConstraint*) layoutConstraintWithIdentifier:(NSString*)identifier; //only one in a view or nil

- (void) setCornerRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor*)color;

- (void) recursivelyClearAllGestures:(BOOL)recursive;

- (void) setAllSubViewToColor:(UIColor*)color;

- (UIButton*) buttonWithTitle:(NSString*)title;

@end

//多个windows的情况，主window被覆盖了， statusbar显示不出来
//改变topWindow的布局，让status Bar显示出来
@interface UIWindow (SubViews)

- (void) showStatusBar;

@end
