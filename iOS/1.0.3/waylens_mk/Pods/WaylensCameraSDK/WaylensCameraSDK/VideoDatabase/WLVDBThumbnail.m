//
//  WLVDBThumbnail.m
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/29.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import "WLVDBThumbnail.h"

@implementation WLVDBThumbnail

- (id)initWithData:(NSData*)data startTime:(double)time duration:(double)duration forClip:(int)clipID withTag:(UInt32)tag {
    return [self initWithData:data startTime:time duration:duration forClip:clipID withTag:tag sessionId:0];
}

- (id)initWithData:(NSData*)data startTime:(double) time duration:(double)duration forClip:(int)clipID withTag:(UInt32)tag sessionId:(int)sessionId {
    self = [super init];
    if (self) {
        _imageData = data;
        _clipID = clipID;
        _pts = time;
        _duration = duration;
        _tag = tag;
        _sessionId = sessionId;
    }
    return self;
}
@end
