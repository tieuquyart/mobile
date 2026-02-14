//
//  UIImage+UIColor.h
//  Hachi
//
//  Created by lzhu on 2/17/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIColor)

//单色单像素的图片
+ (UIImage*) imageWithColor:(UIColor*)color;

//单色图片
+ (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size;

//整张图片
- (UIImage*) imageWithColor:(UIColor*)color blendMode:(CGBlendMode)mode;

//针对图片中的局部位置rect
- (UIImage*) imageWithColor:(UIColor*)color rect:(CGRect)rect blendMode:(CGBlendMode)mode;


@end
