//
//  UIView+Frame.m
//  Hachi
//
//  Created by lzhu on 7/25/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGFloat) x {
    return self.frame.origin.x;
}

- (CGFloat) y {
    return self.frame.origin.y;
}

- (CGFloat) w {
    return self.frame.size.width;
}

- (CGFloat) h {
    return self.frame.size.height;
}

- (CGFloat) midX {
    return self.frame.origin.x + self.frame.size.width/2.0f;
}

- (CGFloat) maxX {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat) midY {
    return self.frame.origin.y + self.frame.size.height/2.0f;
}

- (CGFloat) maxY {
    return self.frame.origin.y + self.frame.size.height;
}

- (void) setX:(CGFloat)x {
    CGPoint center = self.center;
    center.x = x + self.frame.size.width/2.0f;
    self.center = center;
}

- (void) setY:(CGFloat)y {
    CGPoint center = self.center;
    center.y = y + self.frame.size.height/2.0f;
    self.center = center;
}

- (void) setW:(CGFloat)w {
    CGRect frame = self.frame;
    frame.size.width = w;
    self.frame = frame;
}

- (void) setH:(CGFloat)h {
    CGRect frame = self.frame;
    frame.size.height = h;
    self.frame = frame;
}

- (void) setMidX:(CGFloat)midX {
    CGPoint center = self.center;
    center.x = midX;
    self.center = center;
}

- (void) setMidY:(CGFloat)midY {
    CGPoint center = self.center;
    center.y = midY;
    self.center = center;
}

- (void) setMaxX:(CGFloat)maxX {
    CGPoint center = self.center;
    center.x = maxX - self.frame.size.width/2.0f;
    self.center = center;
}

- (void) setMaxY:(CGFloat)maxY {
    CGPoint center = self.center;
    center.y = maxY - self.frame.size.height/2.0f;
    self.center = center;
}

- (CGFloat) sx {
    return self.bounds.origin.x;
}

- (CGFloat) sy {
    return self.bounds.origin.y;
}

- (CGFloat) midsx {
    return self.bounds.origin.x + self.w/2.0f;
}

- (CGFloat) midsy {
    return self.bounds.origin.y + self.h/2.0f;
}

- (CGFloat) maxsx {
    return self.bounds.origin.x + self.w;
}

- (CGFloat) maxsy {
    return self.bounds.origin.y + self.h;
}



@end
