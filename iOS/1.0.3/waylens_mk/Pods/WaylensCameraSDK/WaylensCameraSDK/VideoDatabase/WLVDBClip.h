//
//  WLVDBClip.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/29.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurityEvent.h"

typedef NS_ENUM(NSUInteger, WLClipListType) {
    WLClipListTypeBookMark,
    WLClipListTypeManual,
    WLClipListTypeLoop,
};

NS_ASSUME_NONNULL_BEGIN

@interface WLVDBID: NSObject

@end

@interface WLVDBClip: NSObject

@property (nonatomic, assign, readonly, getter=clipID) int clipID;
@property (nonatomic, assign, readonly, getter=clipType) int clipType;
@property (nonatomic, strong, readonly, getter=uuid) NSString *uuid;
@property (nonatomic, strong, readonly, getter=vin) NSString *vin;
@property (nonatomic, strong, readonly, getter=sn) NSString *sn;
@property (nonatomic, assign, readonly, getter=gmtoff) int gmtoff;
@property (nonatomic, assign, readonly, getter=startTime) double startTime;
@property (nonatomic, assign, readonly, getter=duration) double duration;
@property (nonatomic, assign, readonly, getter=startDate) double startDate; // seconds from 1970 (when the clip was created)
@property (nonatomic, assign, readonly, getter=isManual) BOOL isManual;
@property (nonatomic, assign, readonly, getter=isLive) BOOL isLive;
@property (nonatomic, assign, readonly, getter=streamNum) int streamNum;
@property (nonatomic, strong, readonly, getter=resolutions) NSArray<NSString *> *resolutions;
@property (nonatomic, strong, readonly, getter=vdbID, nullable) WLVDBID *vdbID;

@property (nonatomic, assign, readonly, getter=realClipID) int realClipID;
@property (nonatomic, assign) BOOL isRotated;
@property (nonatomic, assign) BOOL isHDR;
@property (nonatomic, assign) BOOL needDewarp;
@property (nonatomic, assign, readonly, getter=eventType) VIDEO_EVENT_TYPE eventType;
@property (nonatomic, assign, readonly, getter=eventDate) double eventDate;
@property (nonatomic, strong, readonly, getter=recordConfig) NSString *recordConfig;

- (BOOL)isMP4ForStream:(int)index;

@end

NS_ASSUME_NONNULL_END
