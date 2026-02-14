//
//  UINavigationBar+Progress.m
//  Hachi
//
//  Created by lzhu on 3/16/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "UINavigationBar+Progress.h"
#import "UIColor+HEX.h"

@implementation UINavigationBar (Progress)


- (BOOL) enableProgress {
    UIView *view = [self viewWithTag:111100];
    return view != nil;
}

- (void) setEnableProgress:(BOOL)enableProgress {
    if(enableProgress) {
        if(!self.enableProgress) {
            [self addProgress];
        }
    } else {
        [self removeProgress];
    }
}

- (void) addProgress {
    CGSize size = self.frame.size;
    CGFloat min = MIN(size.width, size.height);
    CGFloat max = MAX(size.width, size.height);
    UIView *backgroundView = [[UIView alloc] initWithFrame:(CGRect){0, min-1, max, 1}];
    UIView *progressView = [[UIView alloc] initWithFrame:(CGRect){0, 0, max, 1}];
    [backgroundView addSubview:progressView];
    backgroundView.tag = 111100;
    progressView.tag = 111101;
    backgroundView.backgroundColor = [UIColor colorWithHEX:0x1d1f23 Alpha:1.0f];
    progressView.backgroundColor = [UIColor colorWithHEX:0xFE5000 Alpha:1.0f];
    [self addSubview:backgroundView];
}

- (void) removeProgress {
    UIView *view = [self viewWithTag:111100];
    if(view) {
        [view removeFromSuperview];
    }
}

- (void) setProgress:(CGFloat)progress {
    UIView *backgroundView = [self viewWithTag:111100];
    UIView *progressView = [self progressView];
    if(progressView) {
        progressView.frame = CGRectMake(0, 0, backgroundView.frame.size.width*progress, 1);
    }
}

- (BOOL) progressHidden {
    UIView *backgroundView = [self viewWithTag:111100];
    return backgroundView? backgroundView.hidden : YES;
}

- (void) setProgressHidden:(BOOL)progressHidden {
    UIView *backgroundView = [self viewWithTag:111100];
    if(backgroundView) {
        backgroundView.hidden = progressHidden;
    }
}

- (CGFloat) progress {
    UIView *backgroundView = [self viewWithTag:111100];
    if(backgroundView) {
        UIView *progressView = [backgroundView viewWithTag:111101];
        if(progressView) {
            return progressView.frame.size.width / backgroundView.frame.size.width;
        }
    }
    return 0;
}

- (UIColor*) progressBackgroundColor {
    UIView *backgroundView = [self viewWithTag:111100];
    return backgroundView? backgroundView.backgroundColor : nil;
}

- (UIColor*) progressTintColor {
    UIView *backgroundView = [self viewWithTag:111100];
    if(backgroundView) {
        UIView *progressView = [backgroundView viewWithTag:111101];
        return progressView? progressView.backgroundColor : nil;
    }
    return nil;
}

- (void) setProgressBackgroundColor:(UIColor *)progressBackgroundColor {
    UIView *backgroundView = [self viewWithTag:111100];
    if(backgroundView) {
        backgroundView.backgroundColor = progressBackgroundColor;
    }
}

- (void) setProgressTintColor:(UIColor *)progressTintColor {
    UIView *progressView = [self progressView];
    if(progressView) {
        progressView.backgroundColor = progressTintColor;
    }
}

- (UIView*) progressView {
    UIView *backgroundView = [self viewWithTag:111100];
    return (backgroundView? [backgroundView viewWithTag:111101] : nil);
}


@end


@implementation UINavigationBar(ProgressIndicator)

//@property (assign, nonatomic) BOOL enableIndicator;
//
//@property (assign, nonatomic) BOOL indicatorHidden;
//
//@property (strong, nonatomic) NSString *indicatorText;
//
//@property (strong, nonatomic) UIColor *indicatorTextColor;
//
//@property (assign, nonatomic) CGFloat indicatorPosition; //at range of [0, 1], same to property of progress
//
//@property (strong, nonatomic) UIImage *indicatorImage;  //default is nil, and indicator is a rectangle

- (BOOL) enableIndicator {
    return ([self viewWithTag:111102] != nil);
}

- (void) setEnableIndicator:(BOOL)enableIndicator {
    if(enableIndicator) {
        if(!self.enableIndicator) {
            [self addIndicator];
        }
    } else {
        [self removeIndicator];
    }
}

- (void) addIndicator {
    CGSize size = self.frame.size;
    CGFloat min = MIN(size.width, size.height);
    UIView *indicator = [[UIView alloc] initWithFrame:(CGRect){0, min + 1, 20, 20}];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:indicator.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){0, 6, 20, 14}];
    imageView.image = [UIImage imageNamed:@"progress_indicator_bg"];
    label.font = [UIFont systemFontOfSize:10.0f];
    label.textColor = [UIColor whiteColor];
    indicator.tag = 111102;
    imageView.tag = 111103;
    label.tag = 111104;
    [indicator addSubview:imageView];
    [indicator addSubview:label];
    [self addSubview:indicator];
    self.clipsToBounds = NO;
}

- (void) removeIndicator {
    UIView *indicator = [self viewWithTag:111102];
    if(indicator) {
        [indicator removeFromSuperview];
    }
}

- (BOOL) indicatorHidden {
    UIView *indicator = [self viewWithTag:111102];
    return indicator? indicator.hidden : YES;
}

- (void) setIndicatorHidden:(BOOL)indicatorHidden {
    UIView *indicator = [self viewWithTag:111102];
    if(indicator) {
        indicator.hidden = indicatorHidden;
    }
}

- (NSString*) indicatorText {
    UILabel *label = [self viewWithTag:111104];
    return (label? label.text : nil);
}

- (void) setIndicatorText:(NSString *)indicatorText {
    UILabel *label = [self viewWithTag:111104];
    if(label) {
        label.text = indicatorText;
    }
}

- (UIColor*) indicatorTextColor {
    UILabel *label = [self viewWithTag:111104];
    return (label? label.textColor : nil);
}

- (void) setIndicatorTextColor:(UIColor *)indicatorTextColor {
    UILabel *label = [self viewWithTag:111104];
    if(label) {
        label.textColor = indicatorTextColor;
    }
}

- (CGFloat) indicatorPosition {
    CGSize size = self.frame.size;
    CGFloat max = MAX(size.width, size.height);
    UIView *indicator = [self viewWithTag:111102];
    if(indicator) {
        return indicator.frame.origin.x / max;
    }
    return 0;
}

- (void) setIndicatorPosition:(CGFloat)indicatorPosition {
    CGSize size = self.frame.size;
    CGFloat max = MAX(size.width, size.height);
    CGFloat min = MIN(size.width, size.height);
    UIView *indicator = [self viewWithTag:111102];
    if(indicator) {
        indicator.frame = CGRectMake(max*indicatorPosition, min+1, 20, 20);
    }
}

- (UIImage*) indicatorImage {
    UIImageView *imageView = [self viewWithTag:111103];
    return (imageView? imageView.image : nil);
}

- (void) setIndicatorImage:(UIImage *)indicatorImage {
    UIImageView *imageView = [self viewWithTag:111103];
    if(imageView) {
        imageView.image = indicatorImage;
    }
}

@end
