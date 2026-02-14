//
//  UIView+Frame.h
//  Hachi
//
//  Created by lzhu on 7/25/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * when self.transform == CGAffineTransformIdentity
 */

@interface UIView (Frame)

/**
 * In superView's coordinate
 */
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat w;
@property (assign, nonatomic) CGFloat h;

@property (assign, nonatomic) CGFloat midX;
@property (assign, nonatomic) CGFloat maxX;
@property (assign, nonatomic) CGFloat midY;
@property (assign, nonatomic) CGFloat maxY;


/**
 * In self coordinate
 */
@property (assign, nonatomic, readonly) CGFloat sx;
@property (assign, nonatomic, readonly) CGFloat sy;

@property (assign, nonatomic, readonly) CGFloat midsx;
@property (assign, nonatomic, readonly) CGFloat maxsx;
@property (assign, nonatomic, readonly) CGFloat midsy;
@property (assign, nonatomic, readonly) CGFloat maxsy;

@end

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
