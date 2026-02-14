//
//  UIButton+Style.m
//  Hachi
//
//  Created by lzhu on 2/17/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "UIButton+Style.h"
#import "UIImage+UIColor.h"
#import "UIColor+HEX.h"

@implementation UIButton (Style)

+ (UIButton*) whitePrimaryButton {
    UIButton *button = [[UIButton alloc] init];
    [button setForWhitePrimaryButton];
    return button;
}

+ (UIButton*) orangePrimaryButton {
    UIButton *button = [[UIButton alloc] init];
    [button setForOrangePrimaryButton];
    return button;
}

- (void) setForWhitePrimaryButton {
    [self setTitleColor:[UIColor colorWithHEX:0x14161A Alpha:1.0f] forState:(UIControlStateNormal)];
    [self setTitleColor:[UIColor colorWithHEX:0x14161A Alpha:1.0f] forState:(UIControlStateHighlighted)];
    [self setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.3f] forState:(UIControlStateDisabled)];

    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHEX:0xFFFFFF Alpha:0.9f]] forState:(UIControlStateNormal)];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHEX:0xD9D9D9 Alpha:0.9f]] forState:(UIControlStateHighlighted)];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHEX:0xFFFFFF Alpha:0.1f]] forState:(UIControlStateDisabled)];

    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
    self.layer.cornerRadius = 2.0f;
    self.clipsToBounds = YES;
    [self setContentMode:(UIViewContentModeScaleToFill)];
}

- (void) setForOrangePrimaryButton {
    [self setForOrangePrimaryButtonWithRadius:2.0f fontSize:18.0f];
}

- (void) setForOrangePrimaryButtonWithRadius:(CGFloat)radius fontSize:(CGFloat)size {
    self.backgroundColor = [UIColor clearColor];
    [self setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:(UIControlStateNormal)];
    [self setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:(UIControlStateHighlighted)];
    [self setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.3f] forState:(UIControlStateDisabled)];

    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHEX:0xFE5000 Alpha:1.0f]] forState:(UIControlStateNormal)];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHEX:0xD94400 Alpha:1.0f]] forState:(UIControlStateHighlighted)];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHEX:0xFFFFFF Alpha:0.1f]] forState:(UIControlStateDisabled)];
    if(size != 0) {
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:size]];
        [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel layoutIfNeeded];
    }
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
    [self setContentMode:(UIViewContentModeScaleToFill)];
}

- (void) addUnderline {
    [self addUnderlineWithColor: self.titleLabel.textColor];
}

- (void) addUnderlineWithColor:(UIColor*)color {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text];
    NSRange range = NSMakeRange(0, attrStr.length);
    [attrStr addAttribute:NSForegroundColorAttributeName value:self.titleLabel.textColor range:range];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    [attrStr addAttribute:NSFontAttributeName value:self.titleLabel.font range:range];
    [attrStr addAttribute:NSUnderlineColorAttributeName value:color range:range];
    [self setAttributedTitle:attrStr forState:(UIControlStateNormal)];
}

@end
