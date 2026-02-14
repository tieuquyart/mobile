//
//  NSMutableArray+Safe.m
//  Hachi
//
//  Created by lzhu on 4/11/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSMutableArray+Safe.h"

@implementation NSArray(Safe)

- (id) objectAtIndex_safe:(NSUInteger)index {
    if(index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end

@implementation NSMutableArray (Safe)

- (void) addObject_safe:(id)object {
    if(object) {
        [self addObject:object];
    }
}

- (void) insertObject_safe:(id)anObject atIndex:(NSUInteger)index {
    if(anObject) {
        if(index > self.count) {
            [self addObject:anObject];
        } else {
            [self insertObject:anObject atIndex:index];
        }
    }
}

- (void) addObjectsFromArray_safe:(NSArray*)array {
    if(array) {
        [self addObjectsFromArray:array];
    }
}

- (void) removeObjectAtIndex_safe:(NSUInteger)index {
    if(index < self.count) {
        [self removeObjectAtIndex:index];
    }
}

@end
