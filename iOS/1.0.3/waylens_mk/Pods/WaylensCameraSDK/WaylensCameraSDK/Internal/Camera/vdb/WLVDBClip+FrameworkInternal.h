//
//  WLVDBClip+FrameworkInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/29.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>

@interface WLVDBID(FrameworkInternal)

-(id)initWithSize:(int)size data:(NSData *)data;
-(NSData *)getStructVDBID;

@end

@interface WLVDBClip(FrameworkInternal)

- (id)initWithInforData:(NSData*)clipdata type:(int32_t)cliptype needDewarp:(BOOL)dewarp;
- (id)initWithInforExData:(NSData*)clipdata needDewarp:(BOOL)dewarp;
- (void)setVDBID:(const char*)vdbid;

- (void)updateClip:(vdb_msg_ClipInfo_t*)info;

- (double)getFramerateForStream:(int)index;
- (int)getResolutionForStream:(int)index;
- (NSString*)getInforAsString;
//extent
- (void)setClipExtent:(vdb_ack_GetClipExtent_t*)clipExtent;
- (double)getRealStartTime;
- (double)getRealEndTime;

- (void)setNewTimeRangeFrom:(double)from To:(double)to;

@end
