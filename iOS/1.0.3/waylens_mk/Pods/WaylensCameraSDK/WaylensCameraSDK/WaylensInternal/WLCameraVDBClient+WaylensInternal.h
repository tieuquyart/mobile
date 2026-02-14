//
//  WLCameraVDBClient+WaylensInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/11/19.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WLDmsCameraLiveDelegate <NSObject>
//live
- (void)onLiveRSDMS:(nullable NSData *)data;
- (void)onLiveESDMS:(nullable WLDmsData *)dmsData;
@end

@interface WLCameraVDBClient(WaylensInternal)
@property (weak, nonatomic, nullable) id<WLDmsCameraLiveDelegate> dmsLiveDelegate;
@end

NS_ASSUME_NONNULL_END
