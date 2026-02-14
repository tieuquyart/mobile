//
//  NSMutableDictionary+Safe.m
//  Hachi
//
//  Created by lzhu on 4/11/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSMutableDictionary+Safe.h"


@implementation NSMutableDictionary (Safe)

- (void) setObject_safe:(id)anObject forKey:(id<NSCopying>)aKey {
    if(anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

- (void) removeObjectForKey_safe:(id)key {
    if(key) {
        [self removeObjectForKey:key];
    }
}

@end
