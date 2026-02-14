//
//  NSMutableArray+Queue.m
//  Hachi
//
//  Created by lzhu on 3/4/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

+ (id) queue
{
    return [[NSMutableArray alloc] init];
}

- (void) enqueueObject:(id)object
{
    if(object) {
        [self addObject:object];
    }
}
- (void) dequeueObject
{
    if(self.count)
        [self removeObjectAtIndex:0];
}

- (void) enqueueObjectsFromArray:(NSArray *)array {
    [self addObjectsFromArray:array];

}

- (id) backObject
{
    if(![self empty]) {
        return [self lastObject];
    } else {
        return nil;
    }
}
- (id) frontObject
{
    if(![self empty]) {
        return [self firstObject];
    } else {
        return nil;
    }
}
- (BOOL) empty
{
    return (self.count == 0);
}
- (NSUInteger) size
{
    return self.count;
}

@end
