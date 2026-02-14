//
//  UIColor+HEX.h
//  Hachi
//
//  Created by gliu on 15/8/12.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HEX)

+(UIColor*)colorWithHEX:(long)hex Alpha:(CGFloat)alpha;

+(UIColor*)colorWaylensNaviBarWithAlpha:(CGFloat)alpha;
+(UIColor*)colorWaylensBackGroundWithAlpha:(CGFloat)alpha;
+(UIColor*)colorWaylensPanelWithAlpha:(CGFloat)alpha;
+(UIColor*)colorWaylensTintWithAlpha:(CGFloat)alpha;
+(UIColor*)colorWaylensLightWithAlpha:(CGFloat)alpha;
+(UIColor*)colorWaylensCellBackgroundWithAlpha:(CGFloat)alpha;
+(UIColor*)colorWaylensCellSelectedBackgroundWithAlpha:(CGFloat)alpha;



@end
