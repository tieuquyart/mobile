//
//  NSMutableDictionary+Safe.h
//  Hachi
//
//  Created by lzhu on 4/11/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Safe)

- (void) setObject_safe:(id)anObject forKey:(id<NSCopying>)aKey;

- (void) removeObjectForKey_safe:(id)key;

@end
