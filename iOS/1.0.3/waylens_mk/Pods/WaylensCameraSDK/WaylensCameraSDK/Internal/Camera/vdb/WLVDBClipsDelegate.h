//
//  WLVDBClipsDelegate.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/11/19.
//  Copyright © 2020 Waylens. All rights reserved.
//

@protocol WLVDBClipsDelegate <NSObject>
- (void)onVDBState:(BOOL)canAccess;
- (void)onGetClips:(NSArray *)clips inDomain:(WLVDBDomain)domain;
- (void)onClipRemove:(int)clipid inDomain:(WLVDBDomain)domain;
- (void)onClipUpdate:(vdb_msg_ClipInfo_t *)infor;
- (void)onGetClipInfo:(WLVDBClip *)clip for:(int)clipid;

- (NSString *)getRecordConfigFromClip:(int32_t)clipID inDomain:(WLVDBDomain)clip_type;

@end
