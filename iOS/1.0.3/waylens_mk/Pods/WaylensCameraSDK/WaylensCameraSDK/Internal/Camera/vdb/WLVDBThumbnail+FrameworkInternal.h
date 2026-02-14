//
//  WLVDBThumbnail+FrameworkInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/29.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>

@interface WLVDBThumbnail(FrameworkInternal)

- (id)initWithData:(NSData*)data startTime:(double) time duration:(double)duration forClip:(int)clipID withTag:(UInt32)tag;
- (id)initWithData:(NSData*)data startTime:(double) time duration:(double)duration forClip:(int)clipID withTag:(UInt32)tag sessionId:(int)sessionId;

@end
