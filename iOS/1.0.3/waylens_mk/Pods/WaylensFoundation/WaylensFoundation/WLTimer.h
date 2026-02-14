//
//  WLTimer.h
//  Hachi
//
//  Created by lzhu on 7/8/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLTimer : NSObject

@property (strong, nonatomic) NSString *name;

@property (weak, nonatomic, readonly) id reference;

@property (copy, nonatomic) dispatch_block_t block;

@property (assign, nonatomic) NSTimeInterval interval;
@property (strong, nonatomic) NSDate *startTime;

@property (assign, nonatomic) BOOL repeat;
@property (assign, nonatomic) NSInteger remainingCount;
@property (assign, nonatomic, readonly) BOOL isValid;

- (instancetype)initWithReference:(id)object interval:(NSTimeInterval)interval repeat:(BOOL)repeat block:(dispatch_block_t)block;
- (instancetype) initWithReference:(id)object interval:(NSTimeInterval)interval repeatTimes:(NSInteger)repeatTimes block:(dispatch_block_t)block;
- (void) start;

- (void) stop;

@end
