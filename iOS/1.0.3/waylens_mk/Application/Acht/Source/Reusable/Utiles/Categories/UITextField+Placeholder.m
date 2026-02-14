//
//  UITextField+Placeholder.m
//  Hachi
//
//  Created by lzhu on 2/26/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "UITextField+Placeholder.h"

@implementation UITextField (Placeholder)

- (void) setPlaceholderTextCollor:(UIColor *)placeholderTextCollor {
    [self setValue:placeholderTextCollor forKeyPath:@"_placeholderLabel.textColor"];
}

- (UIColor*) placeholderTextCollor {
    return [self valueForKeyPath:@"_placeholderLabel.textColor"];
}

- (void) setCursorColor:(UIColor *)cursorColor {
    self.tintColor = cursorColor;
}

- (UIColor*) cursorColor {
    return self.tintColor;
}

- (void) setPlaceholderTextFont:(UIFont *)placeholderTextFont {
    [self setValue:placeholderTextFont forKeyPath:@"_placeholderLabel.font"];
}

- (UIFont *)placeholderTextFont {
    return [self valueForKeyPath:@"_placeholderLabel.font"];
}

@end
