//
//  NSMutableArray+Stack.h
//  Hachi
//
//  Created by lzhu on 3/4/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

// @see C++ std::stack

@interface NSMutableArray (Stack)

+ (id) stack;

- (void) pushObject:(id)object;

- (void) popObject;

- (void) pushObjectsFromArray:(NSArray*)array;

- (id) topObject;

- (NSUInteger) size;

- (BOOL) empty;

@end
