//
//  WLCameraVDBClient+FrameworkInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/28.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>
#import "WLVDBClipsDelegate.h"

@protocol VDBPlayListDelegate <NSObject>
- (void)onAllPlaylists:(NSArray*)list;
- (void)onGetClips:(NSArray*)clips forPlayList:(int)index;
- (void)onPlaylistClear:(int)status;
- (void)onClipInsert:(int)res;
- (void)onClipMove:(BOOL)done;
- (void)onGetPlayListPlayURL:(NSString *)url tag:(int)tag;
@end

@protocol VDBShareSourceDelegate <NSObject>
- (void)onGetUploadURL:(NSString *)url atTime:(double)start duration:(double)duration option:(int32_t)option tag:(int)tag;
- (void)onGetDownloadURL:(NSString *)mainurl mainsize:(double)mainsizek
                     sub:(NSString *)subUrl subsize:(double)subsizek
                    subn:(NSString *)subnUrl subnsize:(double)subnsizek
                    Date:(NSDate*)mainDate length:(unsigned int)length forCapture:(long)forcap;
@end

@protocol VDBRawDataRequestDelegate <NSObject>
// block
- (void)onGPSPathUpdateclip:(int)clip path:(NSArray*)path inDomain:(WLVDBDomain)domain;
- (void)onACCPathUpdateclip:(int)clip array:(NSArray*)array inDomain:(WLVDBDomain)domain;
- (void)onOBDPathUpdateclip:(int)clip array:(NSArray*)array inDomain:(WLVDBDomain)domain;

@end

@protocol WLCameraSpaceDelegate <NSObject>

- (void)onGetCameraSpaceTotal:(long long)total free:(long long)free clip:(long long)clip marked:(long long)marked;

@end

@interface WLCameraVDBClient(FrameworkInternal)

@property (weak, nonatomic) id<VDBPlayListDelegate> playlistDelegate;
@property (weak, nonatomic) id<WLCameraSpaceDelegate> spaceDelegate;
@property (weak, nonatomic) id<WLVDBClipsDelegate> clipsDelegate;
@property (weak, nonatomic) id<VDBShareSourceDelegate> shareDelegate;
@property (weak, nonatomic) id<VDBRawDataRequestDelegate> cacheDelegate;

@property (assign, nonatomic) BOOL isReady;
@property (assign, nonatomic) BOOL isCamera;
@property (assign, nonatomic) char vdbVersionMajor;
@property (assign, nonatomic) char vdbVersionMinor;
@property (assign, nonatomic) char osType;
@property (assign, nonatomic) BOOL hasVDBID;
@property (assign, nonatomic) BOOL needDewarp;

@property (assign, nonatomic) int markBefore;
@property (assign, nonatomic) int markAfter;
@property (assign, nonatomic) uint32_t sessionId;

- (void)onGetThumbnail;
- (void)setOptionsNoDelay;

- (void)refreshSessionId;
- (BOOL)updateSpaceInfo;

- (BOOL)getVDBClipInfoForClip:(int)clipid inDomain:(WLVDBDomain)domain;

- (void)getVDBClipsforDomain:(WLVDBDomain)domain tag:(int32_t)tag;
- (void)getThumbnailForClip:(int)clipid inDomain:(WLVDBDomain)domain atTime:(double)point tag:(uint32_t)tag canBeIgnore:(BOOL)canIgnore withID:(WLVDBID *)vdbid;
- (void)getDownloadURLForClip:(int)clipid inDomain:(WLVDBDomain)domain From:(double)point length:(double)length main:(BOOL)bmain sub:(BOOL)bsub subn:(int)subn forCapture:(int)cap withID:(WLVDBID *)vdbid;
- (void)getPlayURLForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point stream:(int)main type:(int)type withID:(WLVDBID *)vdbid Tag:(uint32_t)tag;
- (void)getRawUploadURLForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)length withID:(WLVDBID *)vdbid Tag:(uint32_t)tag;
- (void)getVideoUploadURLForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)length stream:(BOOL)main withID:(WLVDBID *)vdbid Tag:(uint32_t)tag;

- (void)getRawDataForClip:(int)clipid inDomain:(WLVDBDomain)domain Attime:(double)point withID:(WLVDBID *)vdbid;
- (void)getRawDataBlockForClip:(int)clipid inDomain:(WLVDBDomain)domain dataType:(int)type Attime:(double)point length:(double)sec tag:(int16_t)tag userData:(int)userData userData2:(int)userData2 forCache:(BOOL)bcache withID:(WLVDBID *)vdbid;

//for live
- (void)getLiveRawDataWithACC:(BOOL)acc GPS:(BOOL)gps OBD:(BOOL)obd;
- (void)getLiveDMSData:(BOOL)enable;
@end

