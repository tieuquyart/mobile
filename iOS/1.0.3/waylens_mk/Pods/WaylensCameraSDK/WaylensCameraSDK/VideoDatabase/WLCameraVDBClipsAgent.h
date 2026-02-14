//
//  WLCameraVDBClipsAgent.h
//  Hachi
//
//  Created by gliu on 16/4/15.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WLCameraVDBClient.h"
#import "WLVDBClip.h"

@protocol WLCameraVDBClipsAgentDelegate <NSObject>

- (void)onVDBReady:(BOOL)isReady;
- (void)onClipListLoaded:(WLClipListType)listType;
- (void)onNewClip:(WLVDBClip *)clip toList:(WLClipListType)listType;
- (void)onRemoveClip:(WLVDBClip *)clip fromList:(WLClipListType)listType;
- (void)onUpdateClip:(WLVDBClip *)clip fromList:(WLClipListType)listType;

@end

@interface WLCameraVDBClipsAgent: NSObject 

@property (nonatomic, weak, readonly) WLCameraVDBClient *vdb;

- (void)addDelegate:(id<WLCameraVDBClipsAgentDelegate>)dele NS_SWIFT_NAME(add(delegate:));
- (void)removeDelegate:(id<WLCameraVDBClipsAgentDelegate>)dele NS_SWIFT_NAME(remove(delegate:));

- (NSArray<WLVDBClip *> *)listOfType:(WLClipListType)type;

// Call after done formatting memory card.
- (void)refreshVdbState;

@end
