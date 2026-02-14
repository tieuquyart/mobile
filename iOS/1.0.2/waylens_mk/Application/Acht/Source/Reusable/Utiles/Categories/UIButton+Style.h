//
//  UIButton+Style.h
//  Hachi
//
//  Created by lzhu on 2/17/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Style)

+ (UIButton*) whitePrimaryButton;

+ (UIButton*) orangePrimaryButton;

- (void) setForWhitePrimaryButton;

- (void) setForOrangePrimaryButton;

- (void) addUnderline;  //white color underline

- (void) setForOrangePrimaryButtonWithRadius:(CGFloat)radius fontSize:(CGFloat)size;

- (void) addUnderlineWithColor:(UIColor*)color;

@end
