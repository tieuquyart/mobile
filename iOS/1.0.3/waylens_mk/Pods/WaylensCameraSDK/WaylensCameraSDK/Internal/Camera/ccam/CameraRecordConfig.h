//
//  CameraRecordConfig.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/23.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLCameraRecordConfig: NSObject
@property (nonatomic, assign, readonly) int minBitrateFactor;
@property (nonatomic, assign, readonly) int maxBitrateFactor;
@property (nonatomic, copy, readonly) NSString* recordConfig;
@property (nonatomic, assign, readonly) int bitrateFactor;
@property (nonatomic, assign, readonly) int forceCodec;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
