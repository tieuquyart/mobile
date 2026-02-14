//
//  WLCameraVDBClipsAgent+FrameworkInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/29.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>
#import "WLVDBClipsDelegate.h"

@interface WLCameraVDBClipsAgent(FrameworkInternal) <WLVDBClipsDelegate>

- (id)initWithVDB:(WLCameraVDBClient *)pVdb;

- (WLVDBClip *)bufferedClipForMarkClip:(WLVDBClip *)clip;
- (WLVDBClip *)clipForMarkClipWithID:(int)clipID;
@end
