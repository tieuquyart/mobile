//
//  WLTimer.m
//  Hachi
//
//  Created by lzhu on 7/8/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "WLTimer.h"

@interface WLTimer()
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) BOOL limitedRepeat;
@end

@implementation WLTimer

- (instancetype) initWithReference:(id)object interval:(NSTimeInterval)interval repeatTimes:(NSInteger)repeatTimes block:(dispatch_block_t)block {
    self = [super init];
    if(self) {
        _reference = object;
        _block = block;
        _interval = interval;
        if (repeatTimes > 0) {
            _repeat = true;
            _limitedRepeat = true;
            _remainingCount = repeatTimes;
        }
    }
    return self;
}

- (instancetype) initWithReference:(id)object interval:(NSTimeInterval)interval repeat:(BOOL)repeat block:(dispatch_block_t)block {
    self = [super init];
    if(self) {
        _reference = object;
        _block = block;
        _interval = interval;
        _repeat = repeat;
    }
    return self;
}


-(BOOL)isValid{
    return _timer!=nil && _timer.isValid;
}


- (void) start{
    if(_timer == nil) {
        self.startTime = [NSDate date];
        _timer = [NSTimer timerWithTimeInterval:self.interval target:self selector:@selector(run) userInfo:nil repeats:self.repeat];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        if (_repeat) {
            __weak typeof(self) weakself = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself run];
            });
        }
    }
}

- (void) stop{
    if(_timer) {
        [_timer invalidate];
        _timer = nil;
//        printf("\nStop Timer %s\n\n", [self.name UTF8String]);
    }
}

- (void) run {
    if(self.reference != nil && self.block != nil) {
        if (_limitedRepeat) {
            _remainingCount -= 1;
        }
        self.block();
        if (_limitedRepeat && _remainingCount <= 0) {
            [self stop];
        }
    } else {
        [self stop];
    }
}


@end
