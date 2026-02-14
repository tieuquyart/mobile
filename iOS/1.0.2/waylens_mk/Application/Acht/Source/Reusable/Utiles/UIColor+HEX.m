//
//  UIColor+HEX.m
//  Hachi
//
//  Created by gliu on 15/8/12.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import "UIColor+HEX.h"

@implementation UIColor (HEX)

+(UIColor*) colorWithHEX:(long)hex Alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((hex>>16)&255)/255.0 green:((hex>>8)&255)/255.0 blue:((hex)&255)/255.0 alpha:alpha];
}

+(UIColor*)colorWaylensNaviBarWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithHEX:0x1d1f23 Alpha:alpha];
//    return [UIColor colorWithHEX:0x141618 Alpha:alpha];
}

+(UIColor*)colorWaylensBackGroundWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithHEX:0x1d1f23 Alpha:alpha];
}

+(UIColor*)colorWaylensPanelWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithHEX:0x141618 Alpha:alpha];
}

+(UIColor*)colorWaylensTintWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithHEX:0xfe5000 Alpha:alpha];
}
+(UIColor*)colorWaylensLightWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithHEX:0xd8d8d8 Alpha:alpha];
}
+(UIColor*)colorWaylensCellBackgroundWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithHEX:0x222428 Alpha:alpha];
}
+(UIColor*)colorWaylensCellSelectedBackgroundWithAlpha:(CGFloat)alpha {
    return [UIColor colorWithHEX:0x17191c Alpha:alpha];
}
@end
