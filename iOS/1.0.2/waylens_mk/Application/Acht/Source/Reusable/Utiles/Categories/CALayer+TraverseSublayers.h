//
//  CALayer+TraverseSublayers.h
//  TuTu
//
//  Created by lzhu on 1/8/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (TraverseSublayers)

//打印出当前Layer的所有subllayers， 用于分析CALayer及其子类的组合结构
- (void) travertraverseAllSublayersRecursively:(BOOL)recursive;

@end
