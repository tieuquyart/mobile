//
//  NSMutableArray+Queue.h
//  Hachi
//
//  Created by lzhu on 3/4/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

//@see std::queue in C++

@interface NSMutableArray (Queue)

+ (id) queue;

- (void) enqueueObject:(id)object; //at back

- (void) dequeueObject; //from front

- (void) enqueueObjectsFromArray:(NSArray*)array;

- (id) backObject;

- (id) frontObject;

- (BOOL) empty;

- (NSUInteger) size;

@end
