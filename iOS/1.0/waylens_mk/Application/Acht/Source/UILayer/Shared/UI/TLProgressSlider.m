//
//  TLProgressSlider.m
//  Hachi
//
//  Created by Waylens Administrator on 7/29/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "TLProgressSlider.h"
#define TLProgressSliderMargin 4.0f

@interface TLProgressSlider()
@property (nonatomic, strong) UIImage *thumb;
@property (nonatomic, assign) NSTimeInterval lastChangedTime;
@property (nonatomic, strong) UIView *progressView;
@end

@implementation TLProgressSlider

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

-(UIView *)progressView{
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1 alpha:0.6];
        [self insertSubview:_progressView atIndex:1];
    }
    return _progressView;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self layoutProgressView];
}

-(void)layoutProgressView{
    CGRect frame = [self trackRectForBounds:self.bounds];
    CGFloat width = (self.progress - self.value) * frame.size.width;
    CGFloat x = self.value * frame.size.width;
    self.progressView.frame = CGRectMake(x+frame.origin.x, frame.origin.y, width, frame.size.height);
}

-(void)setup{
    [self setThumbImage:self.thumb forState:UIControlStateNormal];
    _progress = 0;
    self.value = 0;
    self.refreshInterval = 0.1;
    self.tintColor = [UIColor whiteColor];
    self.maximumTrackTintColor = [UIColor darkGrayColor];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(tapAndSlide:)];
    longPress.minimumPressDuration = 0; // must be 0, to override interaction on slider
    [self addGestureRecognizer:longPress];
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self layoutProgressView];
}

-(UIImage *)thumb{
    if (!_thumb) {
        _thumb = [self thumbForSize:CGSizeMake(3, 12)];
    }
    return _thumb;
}

-(UIImage *)thumbForSize:(CGSize)size{
    if (!(_thumb && _thumb.size.height==size.height && _thumb.size.width==size.width)) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect rectangle = CGRectMake(0, 0, size.width, size.height);
        CGContextAddRect(context, rectangle);
        CGContextSetFillColorWithColor(context,
                                       [UIColor whiteColor].CGColor);
        CGContextFillRect(context, rectangle);
        _thumb = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _thumb;
}

- (CGRect)thumbRect {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    return [self thumbRectForBounds:self.bounds trackRect:trackRect value:self.value];
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect frame = [super trackRectForBounds:bounds];
    frame.origin.x += TLProgressSliderMargin;
    frame.size.width -= TLProgressSliderMargin * 2;
    return frame;
}

//- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
//    CGRect frame = [super thumbRectForBounds:bounds trackRect:rect value:value];
//    CGFloat width = 12.0f;
//    frame.origin.x -= 0.5*(width-frame.size.width);
//    frame.size.width = width;
//    return frame;
//}

- (void)tapAndSlide:(UILongPressGestureRecognizer*)gesture
{
    CGPoint pt = [gesture locationInView: self];
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    pt.x -= trackRect.origin.x;
    pt.y -= trackRect.origin.y;
    CGFloat thumbWidth = [self thumbRect].size.width;
    CGFloat value;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (pt.x <= thumbWidth/2.0)
        value = self.minimumValue;
    else if(pt.x >= trackRect.size.width - thumbWidth/2.0)
        value = self.maximumValue;
    else {
        CGFloat percentage = (pt.x - thumbWidth/2.0)/(trackRect.size.width - thumbWidth);
        CGFloat delta = percentage * (self.maximumValue - self.minimumValue);
        value = self.minimumValue + delta;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan){
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setValue:value animated:YES];
            [super sendActionsForControlEvents:UIControlEventValueChanged];
        } completion:nil];
        self.lastChangedTime = now;
        self.isDragging = YES;
        if ([self.delegate respondsToSelector:@selector(slideBegan)]) {
            [self.delegate slideBegan];
        }
    }
    else [self setValue:value];
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (now - self.lastChangedTime>self.refreshInterval) {
            [super sendActionsForControlEvents:UIControlEventValueChanged];
            self.lastChangedTime = now;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [super sendActionsForControlEvents:UIControlEventValueChanged];
        self.lastChangedTime = now;
        self.isDragging = NO;
        if ([self.delegate respondsToSelector:@selector(slideEnded)]) {
            [self.delegate slideEnded];
        }
    }
}

@end
