//
//  WLVDBThumbnail.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/29.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLVDBThumbnail: NSObject

@property (nonatomic, strong, readonly) NSData* imageData;
@property (nonatomic, assign, readonly) int clipID;
@property (nonatomic, assign, readonly) double pts;
@property (nonatomic, assign, readonly) double duration;
@property (nonatomic, assign, readonly) UInt32 tag;
@property (nonatomic, assign, readonly) int sessionId;

@end
