//
//  NSMutableArray+Stack.m
//  Hachi
//
//  Created by lzhu on 3/4/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

+ (id) stack
{
    return [[NSMutableArray alloc] init];
}

- (void) pushObject:(id)object
{
    if(object != nil)
        [self addObject:object];
}

- (void) popObject
{
    if(![self empty])
        [self removeLastObject];
}

- (void) pushObjectsFromArray:(NSArray*)array {
    if(array)
        [self addObjectsFromArray:array];
}

- (id) topObject
{
    if(![self empty])
        return [self lastObject];
    return nil;
}

- (NSUInteger) size
{
    return self.count;
}
- (BOOL) empty
{
    return (self.count == 0);
}

@end
