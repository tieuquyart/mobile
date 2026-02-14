//
//  CALayer+TraverseSublayers.m
//  TuTu
//
//  Created by lzhu on 1/8/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "CALayer+TraverseSublayers.h"

@implementation CALayer (TraverseSublayers)


- (void) travertraverseAllSublayersRecursively:(BOOL)recursive {
    NSLog(@"%@ object tree :", [self class]);
    [self traverseAllSublayersAtLevel:1 recursively:YES];
}


- (void) traverseAllSublayersAtLevel:(NSInteger)level recursively:(BOOL)recursive {
    for(CALayer *layer in self.sublayers) {
        NSMutableString *mstr = [NSMutableString string];
        for(NSInteger idx = 0; idx < level; ++idx) {
            [mstr appendString:@"\t"];
        }
        [mstr appendFormat:@"%@", NSStringFromClass([layer class])];
        NSLog(@"%@", mstr);
        if(recursive) {
            [layer traverseAllSublayersAtLevel:level+1 recursively:recursive];
        }
    }
}

@end
