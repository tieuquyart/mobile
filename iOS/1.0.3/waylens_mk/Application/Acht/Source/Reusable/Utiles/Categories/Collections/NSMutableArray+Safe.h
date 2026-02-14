//
//  NSMutableArray+Safe.h
//  Hachi
//
//  Created by lzhu on 4/11/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Safe)

- (id) objectAtIndex_safe:(NSUInteger)index;

@end

@interface NSMutableArray (Safe)

- (void) addObject_safe:(id)object;

- (void) insertObject_safe:(id)anObject atIndex:(NSUInteger)index;

- (void) addObjectsFromArray_safe:(NSArray*)array;

- (void) removeObjectAtIndex_safe:(NSUInteger)index;

@end
