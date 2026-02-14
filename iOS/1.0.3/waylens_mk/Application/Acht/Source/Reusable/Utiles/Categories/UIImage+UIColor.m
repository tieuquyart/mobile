//
//  UIImage+UIColor.m
//  Hachi
//
//  Created by lzhu on 2/17/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "UIImage+UIColor.h"

@implementation UIImage (UIColor)

+ (UIImage*) imageWithColor:(UIColor *)color {
    CGSize size = CGSizeMake(1, 1);
    return [self imageWithColor:color size:size];
}

+ (UIImage*) imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage*) imageWithColor:(UIColor*)color blendMode:(CGBlendMode)mode {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [color set];
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(rect);
    [self drawInRect:rect blendMode:mode alpha:1.0f];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*) imageWithColor:(UIColor*)color rect:(CGRect)rect blendMode:(CGBlendMode)mode {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [color set];
    CGRect myrect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:myrect blendMode:mode alpha:1.0f];
    UIRectFill(rect);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
