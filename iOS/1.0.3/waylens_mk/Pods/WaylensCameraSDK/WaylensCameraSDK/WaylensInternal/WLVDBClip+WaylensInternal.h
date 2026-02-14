//
//  WLVDBClip+WaylensInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/11/12.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>

@interface WLVDBClip(WaylensInternal)
@property (nonatomic, assign, readonly, getter=dmsIndex) int dmsIndex; // internal raw data index
@property (nonatomic, assign, readonly, getter=dmsType) DMS_STATUS dmsType;
@property (nonatomic, assign, readonly, getter=dmsDate) double dmsDate;
@property (nonatomic, assign, readonly, getter=adasType) ADAS_STATUS adasType;
@property (nonatomic, assign, readonly, getter=adasDate) double adasDate;
@end
