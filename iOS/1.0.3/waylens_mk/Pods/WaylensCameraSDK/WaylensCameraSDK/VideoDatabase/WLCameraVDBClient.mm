//
//  CameraVDBClient.mm
//  Vidit
//
//  Created by gliu on 15/1/13.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import "WLCameraVDBClient.h"
#import "WLCameraVDBClient+FrameworkInternal.h"
#import "WLVDBThumbnail+FrameworkInternal.h"
#import "WLCameraVDBClipsAgent+FrameworkInternal.h"
#import "WLVDBClip+FrameworkInternal.h"
#import "Define+FrameworkInternal.h"
#import "WLVDBThumbnailCache.h"
#import "WLCameraVDBClient+WaylensInternal.h"
#import "vdb_cmd.h"

#define NewCmdBuffer(a) char a[VDB_CMD_SIZE]; memset(a, 0, VDB_CMD_SIZE);

@interface WLCameraVDBClient () {

    //for thumbnail
    NSMutableArray* naviBarCanbeIgnoreThumbnailCMDs;
}
@property (atomic, assign) NSInteger onGoingImgNum;

@property (weak, nonatomic) id<WLDmsCameraLiveDelegate> dmsLiveDelegate;
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

//for playlist
- (void)getAllPlaylists;
- (void)clearPlaylist:(WLVDBDomain)domain;
- (void)getPlaylistIndexPic:(WLVDBDomain)domain tag:(int)tag;
- (void)moveClip:(int)pos inPlaylist:(WLVDBDomain)domain to:(int)newpos;
- (void)insertClip:(int)clipid FromDomain:(WLVDBDomain)domain To:(int)playlistindex from:(double)point length:(double)sec;

- (BOOL)getVDBAllClips;// VDBClientDeprecated("Please use GetVDBClipsforDomain:");

- (BOOL)getVDBClipExtentForClip:(int)clipid inDomain:(WLVDBDomain)domain;
- (BOOL)setVDBClipExtentForClip:(int)clipid inDomain:(WLVDBDomain)domain From:(double)from To:(double)to;
- (BOOL)getTSForClip:(int)clipid inDomain:(WLVDBDomain)domain From:(double)point length:(double)sec stream:(int)main withTag:(long)tag withID:(WLVDBID *)vdbid;

@end

@implementation WLCameraVDBClient

@synthesize isReady;
@synthesize isCamera;
@synthesize vdbVersionMajor;
@synthesize vdbVersionMinor;
@synthesize osType;
@synthesize hasVDBID;

- (nonnull instancetype)initWithIPv4:(nullable NSString *)ipv4 IPv6:(nullable NSString *)ipv6 port:(long)port {
    self = [super initWithIPv4:ipv4 IPv6:ipv6 port:port];
    if (self) {
        if(isatty(STDOUT_FILENO)) {
            self.heartBeatInterval = -1;
//            self.heatBeatInterval = 4;
        } else {
            self.heartBeatInterval = 4;
        }
        vdbVersionMajor = 0;
        vdbVersionMinor = 0;
        isReady = YES;
        osType = 0;
        hasVDBID = NO;
        _onGoingImgNum = 0;
        naviBarCanbeIgnoreThumbnailCMDs = [[NSMutableArray alloc] init];
        _markAfter = 8;
        _markAfter = 7;
    }
    return self;
}

- (void)refreshSessionId {
    self.sessionId += 1;
}

- (BOOL)sendData:(char*)cmd {
    // do not print here
    //NSLog(@"VDBClient Send CMD:%d", ((vdb_cmd_GetIndexPicture_t*)cmd)->header.cmd_code);
    ((vdb_cmd_GetIndexPicture_t*)cmd)->header.user1 = self.sessionId;
    NSData* pdata = [NSData dataWithBytes:cmd length:VDB_CMD_SIZE];
    [self sendData:pdata withTimeout:5];
    return YES;
}

- (BOOL)updateSpaceInfo {
    if (vdbVersionMinor >= 5 && vdbVersionMajor >= 1) {
        NewCmdBuffer(tmp)
        vdb_cmd_GetSpaceInfo_t* cmd = (vdb_cmd_GetSpaceInfo_t*)tmp;
        cmd->header.cmd_code = VDB_CMD_GetSpaceInfo;
        NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
        return [self sendData:tmp];
    } else {
//        NSLog(@"updateSpaceInfo, wrong version: %d.%d", mVDBVersionMajor, mVDBVersionMinor);
        return NO;
    }
}
- (BOOL)getVDBClipExtentForClip:(int)clipid inDomain:(WLVDBDomain)domain {
    if (vdbVersionMinor >= 2 && vdbVersionMajor >= 1) {
        NewCmdBuffer(tmp)
        vdb_cmd_GetClipExtent_t* cmd = (vdb_cmd_GetClipExtent_t*)tmp;
        cmd->header.cmd_code = VDB_CMD_GetClipExtent;
        cmd->clip_id = clipid;
        cmd->clip_type = domain;
        return [self sendData:tmp];
    } else {
        NSLog(@"GetVDBClipExtentForClip, wrong version: %d.%d", vdbVersionMajor, vdbVersionMinor);
        return NO;
    }
}
- (BOOL)setVDBClipExtentForClip:(int)clipid inDomain:(WLVDBDomain)domain From:(double)from To:(double)to {
    if (vdbVersionMinor >= 2 && vdbVersionMajor >= 1) {
        NewCmdBuffer(tmp)
        vdb_cmd_SetClipExtent_t* cmd = (vdb_cmd_SetClipExtent_t*)tmp;
        cmd->header.cmd_code = VDB_CMD_SetClipExtent;
        cmd->clip_id = clipid;
        cmd->clip_type = domain;
        unsigned long long tt = from * 1000;
        cmd->new_clip_start_time_ms_hi = tt >> 32;
        cmd->new_clip_start_time_ms_lo = tt & 0x0ffffffff;
        tt = to * 1000;
        cmd->new_clip_end_time_ms_hi = tt >> 32;
        cmd->new_clip_end_time_ms_lo = tt & 0x0ffffffff;
        return [self sendData:tmp];
    } else {
        NSLog(@"SetVDBClipExtentForClip, wrong version: %d.%d", vdbVersionMajor, vdbVersionMinor);
        return NO;
    }
}
- (BOOL)getVDBClipInfoForClip:(int)clipid inDomain:(WLVDBDomain)domain {
    if (vdbVersionMinor >= 2 && vdbVersionMajor >= 1) {
        NewCmdBuffer(tmp)
        vdb_cmd_GetClipInfo_t* cmd = (vdb_cmd_GetClipInfo_t*)tmp;
        cmd->header.cmd_code = VDB_CMD_GetClipInfo;
        cmd->clip_id = clipid;
        cmd->clip_type = domain;
        cmd->flags = GET_CLIP_EXTRA | GET_CLIP_ATTR | GET_CLIP_DESC | GET_CLIP_SCENE_DATA | GET_CLIP_RAW_FCC | GET_CLIP_VIDEO_TYPE | GET_CLIP_VIDEO_DESCR;
        return [self sendData:tmp];
    } else {
        NSLog(@"GetVDBClipInfoForClip, wrong version: %d.%d", vdbVersionMajor, vdbVersionMinor);
        return NO;
    }
}
- (BOOL)getVDBAllClips {
    if (vdbVersionMinor >= 2 && vdbVersionMajor >= 1) {
        NewCmdBuffer(tmp)
        vdb_cmd_GetAllClipSetInfo_t* cmd = (vdb_cmd_GetAllClipSetInfo_t*)tmp;
        cmd->header.cmd_code = VDB_CMD_GetAllClipSetInfo;
        NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
        return [self sendData:tmp];
    } else {
        NSLog(@"GetVDBAllClips, wrong version: %d.%d", vdbVersionMajor, vdbVersionMinor);
        return NO;
    }
}

- (BOOL)getTSForClip:(int)clipid inDomain:(WLVDBDomain)domain From:(double)point length:(double)sec stream:(int)main withTag:(long)tag  withID:(WLVDBID *)vdbid {
    return [self getPlaybackUrlExForClip:clipid inDomain:domain From:point Length:sec Type:URL_TYPE_TS Stream:main withTag:tag withID:vdbid];
}
- (BOOL)getHLSForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)sec stream:(int)main withTag:(long)tag  andID:(WLVDBID *)vdbid {
    return [self getPlaybackUrlExForClip:clipid inDomain:domain From:point Length:sec Type:URL_TYPE_HLS Stream:main withTag:tag withID:vdbid];
}
- (BOOL)getMP4ForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)sec stream:(int)main withTag:(long)tag  andID:(WLVDBID *)vdbid {
    return [self getPlaybackUrlExForClip:clipid inDomain:domain From:point Length:sec Type:URL_TYPE_MP4 Stream:main withTag:tag withID:vdbid];
}

- (BOOL)getPlaybackUrlExForClip:(int)clipid inDomain:(WLVDBDomain)domain From:(double)point Length:(double)sec Type:(uint32_t)type Stream:(int)main withTag:(long)tag  withID:(WLVDBID *)vdbid {
    if (vdbVersionMinor >= 3 && vdbVersionMajor >= 1) {
        NewCmdBuffer(tmp)
        vdb_cmd_GetPlaybackUrlEx_t* cmd = (vdb_cmd_GetPlaybackUrlEx_t*)tmp;
        cmd->inherited.header.cmd_code = VDB_CMD_GetPlaybackUrlEx;
        cmd->inherited.clip_type = domain;
        cmd->inherited.clip_id = clipid;
        cmd->inherited.header.cmd_tag = (uint32_t)tag; //user_data
        cmd->inherited.stream = main;
        cmd->inherited.url_type = type;
        unsigned long long tt = point * 1000;
        cmd->inherited.clip_time_ms_hi = tt >> 32;
        cmd->inherited.clip_time_ms_lo = (tt & 0x0ffffffff);
        cmd->inherited.header.user1 = type;
        cmd->length_ms = sec * 1000;
        if (vdbid != nil) {
            void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetPlaybackUrl_t));
            NSData* data = [vdbid getStructVDBID];
            memcpy(iddata, [data bytes], [data length]);
        }
        NSLog(@"VDBClient Send CMD:%d", cmd->inherited.header.cmd_code);
        return [self sendData:tmp];
    } else {
        NSLog(@"GetTSForClip, wrong version: %d.%d", vdbVersionMajor, vdbVersionMinor);
        return NO;
    }
}
- (void)getVDBClipsforDomain:(WLVDBDomain)domain tag:(int32_t)tag {
    if (isCamera == NO) {
//        return;
    }
    NewCmdBuffer(tmp)
    if (vdbVersionMinor >= 2 && vdbVersionMajor >= 1) {
        vdb_cmd_GetClipSetInfoEx_t* cmd = (vdb_cmd_GetClipSetInfoEx_t*)tmp;
        cmd->inherited.header.cmd_code = VDB_CMD_GetClipSetInfoEx;
        cmd->inherited.clip_type = domain;
        cmd->flags = GET_CLIP_EXTRA | GET_CLIP_ATTR | GET_CLIP_DESC | GET_CLIP_SCENE_DATA | GET_CLIP_RAW_FCC | GET_CLIP_VIDEO_TYPE | GET_CLIP_VIDEO_DESCR;
        cmd->inherited.header.cmd_tag = tag;
        NSLog(@"VDBClient Send CMD:%d", cmd->inherited.header.cmd_code);
    } else {
        vdb_cmd_GetClipSetInfo_t* cmd = (vdb_cmd_GetClipSetInfo_t*)tmp;
        cmd->header.cmd_code = VDB_CMD_GetClipSetInfo;
        cmd->clip_type = domain;
        cmd->header.cmd_tag = tag;
        NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
    }
    [self sendData:tmp];
}

- (void)getThumbnailForClip:(int)clipid inDomain:(WLVDBDomain)domain atTime:(double)point tag:(uint32_t)tag canBeIgnore:(BOOL)canIgnore withID:(WLVDBID *)vdbid {
    [self getThumbnailForClip:clipid inDomain:domain atTime:point tag:tag canBeIgnore:canIgnore withID:vdbid useCache:YES];
}

- (void)getThumbnailForClip:(int)clipid inDomain:(WLVDBDomain)domain atTime:(double)point tag:(uint32_t)tag canBeIgnore:(BOOL)canIgnore withID:(WLVDBID *)vdbid useCache:(BOOL)useCache{
    NewCmdBuffer(tmp)
    vdb_cmd_GetIndexPicture_t* cmd = (vdb_cmd_GetIndexPicture_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetIndexPicture;
    cmd->header.cmd_tag = tag; //user_data
    cmd->header.user2 = (int(canIgnore) << 1) + int(useCache);
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    unsigned long long tt = point * 1000;
    cmd->clip_time_ms_hi = tt >> 32;
    cmd->clip_time_ms_lo = tt & 0x0ffffffff;
    if (vdbid != nil) {
        void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetIndexPicture_t));
        NSData* data = [vdbid getStructVDBID];
        memcpy(iddata, [data bytes], [data length]);
    }
    NSData* pdata = [NSData dataWithBytes:tmp length:VDB_CMD_SIZE];
    if (useCache && [self checkThumnailCMDFromCache:pdata]) {
//        NSLog(@"Thumbnail disk-cached for clip %d, time:%llu, ignorable:%d", clipid, tt, canIgnore);
        return;
    }
    
    //push cmd into queue first, to avoid wrong order
    if (canIgnore && (self.onGoingImgNum > 2)) {
//        NSLog(@"%ld thumbnails on the way", (long)self.onGoingImgNum);
        [naviBarCanbeIgnoreThumbnailCMDs addObject:pdata];
        if (naviBarCanbeIgnoreThumbnailCMDs.count > 4) {
            [naviBarCanbeIgnoreThumbnailCMDs removeObjectAtIndex:0];
        }
        return;
    }
//    NSLog(@"Thumbnail not-cached for clip %d, time:%llu, ignorable:%d", clipid, tt, canIgnore);
    [self sendData:tmp];
    self.onGoingImgNum += 1;
}


- (BOOL)checkThumnailCMDFromCache:(NSData*)cmd {
    NewCmdBuffer(tmp)
    vdb_cmd_GetIndexPicture_t* getThumbnailCmd = (vdb_cmd_GetIndexPicture_t*)tmp;
    [cmd getBytes:tmp length:VDB_CMD_SIZE];
    long long pts = 0;
    long duration = 0;
    long long ms = ((long long)getThumbnailCmd->clip_time_ms_hi << 32) + getThumbnailCmd->clip_time_ms_lo;
    __block NSData* cacheData = [[WLVDBThumbnailCache sharedInstance] getThumbnailAtTimestamp:ms
                                                                                    inClip:getThumbnailCmd->clip_id
                                                                                   ptsInMS:&pts
                                                                              durationInMS:&duration];
    __block int clipid = getThumbnailCmd->clip_id;
    __block int tag = getThumbnailCmd->header.cmd_tag;
    if (cacheData) {
        NSLog(@"Thumbnail disk-cached for clip %d, time:%lld", clipid, ms);
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.requestDelegate respondsToSelector:@selector(onGetThumbnail:)]) {
                [weakSelf.requestDelegate onGetThumbnail:[[WLVDBThumbnail alloc] initWithData:cacheData
                                                                           startTime:pts*0.001
                                                                            duration:duration*.001
                                                                             forClip:clipid
                                                                             withTag:tag]];
            }
//            if (weakSelf.pOneTouchUploadDelegate) {
//                [weakSelf.pOneTouchUploadDelegate OnGetThumbnail:cacheData
//                                                         forClip:clipid
//                                                          atTime:pts * .001
//                                                        duration:duration * .001
//                                                             tag:tag];
//            }
        });
        return YES;
    }
    return NO;
}

- (void)onGetThumbnail {
    self.onGoingImgNum -= 1;
    if (self.onGoingImgNum <= 2 && naviBarCanbeIgnoreThumbnailCMDs.count > 0) {
        NSData* cmd;
        do {
            cmd = naviBarCanbeIgnoreThumbnailCMDs.firstObject;
            [naviBarCanbeIgnoreThumbnailCMDs removeObjectAtIndex:0];
        } while ([self checkThumnailCMDFromCache:cmd] && naviBarCanbeIgnoreThumbnailCMDs.count > 0);
        if (cmd != nil) {
            [self sendData:cmd withTimeout:5];
            self.onGoingImgNum += 1;
        }
    }
}

- (void)getDownloadURLForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)length main:(BOOL)bmain sub:(BOOL)bsub subn:(int)subn tag:(uint32_t)tag {
    NewCmdBuffer(tmp)
    vdb_cmd_GetDownloadUrlEx_t* cmd = (vdb_cmd_GetDownloadUrlEx_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetDownloadUrlEx;
    cmd->header.cmd_tag = tag;
    cmd->header.user1 = 0;
    cmd->header.user2 = 0;
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    cmd->clip_length_ms = uint32_t(length*1000);
    unsigned long long tt = point * 1000;
    cmd->clip_time_ms_hi = (tt >> 32);
    cmd->clip_time_ms_lo = (tt & 0x0ffffffff);
    cmd->download_opt = 0;
    if (bmain) {
        cmd->download_opt |= DOWNLOAD_OPT_MAIN_STREAM;
        //cmd->download_opt |= DOWNLOAD_OPT_MAIN_MP4;
    }
    if (bsub) {
        cmd->download_opt |= DOWNLOAD_OPT_SUB_STREAM_1;
        //cmd->download_opt |= DOWNLOAD_OPT_SUB_MP4;
    }
    if (subn > 1) {
        cmd->download_opt |= DOWNLOAD_OPT_SUB_STREAM_N;
        //cmd->download_opt |= DOWNLOAD_OPT_SUB_N_MP4;
        cmd->download_opt += subn << 16;
    }
    if (domain >= VDBDomain_Playlist1) {
        cmd->download_opt |= DOWNLOAD_OPT_PLAYLIST;
    }
    NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
    [self sendData:tmp];
}

- (void)getDownloadURLForClip:(int)clipid inDomain:(WLVDBDomain)domain From:(double)point length:(double)length main:(BOOL)bmain sub:(BOOL)bsub subn:(int)subn forCapture:(int)cap withID:(WLVDBID *)vdbid {
    NewCmdBuffer(tmp)
    vdb_cmd_GetDownloadUrlEx_t* cmd = (vdb_cmd_GetDownloadUrlEx_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetDownloadUrlEx;
    cmd->header.cmd_tag = 0;
    cmd->header.user1 = 0;
    cmd->header.user2 = cap;
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    cmd->clip_length_ms = uint32_t(length*1000);
    unsigned long long tt = point * 1000;
    cmd->clip_time_ms_hi = (tt >> 32);
    cmd->clip_time_ms_lo = (tt & 0x0ffffffff);
    cmd->download_opt = 0;
    if (bmain) {
        cmd->download_opt |= DOWNLOAD_OPT_MAIN_STREAM;
    }
    if (bsub) {
        cmd->download_opt |= DOWNLOAD_OPT_SUB_STREAM_1;
    }
    if (subn > 1) {
        cmd->download_opt |= DOWNLOAD_OPT_SUB_STREAM_N;
        //cmd->download_opt |= DOWNLOAD_OPT_SUB_N_MP4;
        cmd->download_opt += subn << 16;
    }
    if ((cap ==0) && domain >= VDBDomain_Playlist1) {
        cmd->download_opt |= DOWNLOAD_OPT_PLAYLIST;
    }
    if (vdbid != nil) {
        void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetDownloadUrlEx_t));
        NSData* data = [vdbid getStructVDBID];
        memcpy(iddata, [data bytes], [data length]);
    }
    NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
    [self sendData:tmp];
}

- (void)getPlayURLForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point stream:(int)main type:(int)type withID:(WLVDBID *)vdbid Tag:(uint32_t)tag {
    NewCmdBuffer(tmp)
    if (domain == VDBDomain_Album || domain == VDBDomain_Mark) {
        vdb_cmd_GetPlaybackUrl_t* cmd = (vdb_cmd_GetPlaybackUrl_t*)tmp;
        cmd->header.cmd_code = VDB_CMD_GetPlaybackUrl;
        cmd->clip_type = domain;
        cmd->clip_id = clipid;
        cmd->header.cmd_tag = tag; //user_data
        cmd->stream = main;
        cmd->url_type = type;
        unsigned long long tt = point * 1000;
        cmd->clip_time_ms_hi = tt >> 32;
        cmd->clip_time_ms_lo = (tt & 0x0ffffffff);
        if (vdbid != nil) {
            void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetPlaybackUrl_t));
            NSData* data = [vdbid getStructVDBID];
            memcpy(iddata, [data bytes], [data length]);
        }
        NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
    } else {
        vdb_cmd_GetPlaylistPlaybackUrl_t* cmd = (vdb_cmd_GetPlaylistPlaybackUrl_t*)tmp;
        cmd->header.cmd_code = VDB_CMD_GetPlaylistPlaybackUrl;
        cmd->list_type = domain;
        cmd->stream = main?STREAM_MAIN:STREAM_SUB_2;
        cmd->url_type = type;
        cmd->header.cmd_tag = tag; //user_data
        unsigned int tt = point * 1000;
        cmd->playlist_start_ms = tt;
        if (vdbid != nil) {
            void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetPlaylistPlaybackUrl_t));
            NSData* data = [vdbid getStructVDBID];
            memcpy(iddata, [data bytes], [data length]);
        }
        NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
    }
    [self sendData:tmp];
}

- (void)getRawUploadURLForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)length withID:(WLVDBID *)vdbid Tag:(uint32_t)tag {
    [self getUploadURLForClip:clipid type:(UPLOAD_GET_GPS|UPLOAD_GET_OBD|UPLOAD_GET_ACC) inDomain:domain from:point length:length withID:vdbid Tag:tag];
}
- (void)getVideoUploadURLForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)length stream:(BOOL)main withID:(WLVDBID *)vdbid Tag:(uint32_t)tag {
    [self getUploadURLForClip:clipid type:(main?UPLOAD_GET_V0:UPLOAD_GET_V1) inDomain:domain from:point length:length withID:vdbid Tag:tag];
}
- (void)getUploadURLForClip:(int)clipid type:(uint32_t)type inDomain:(WLVDBDomain)domain from:(double)point length:(double)length withID:(WLVDBID *)vdbid Tag:(uint32_t)tag {
    if (vdbVersionMinor >= 4 && vdbVersionMajor >= 1) {
        //ok
    } else {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^() {
            [weakSelf.shareDelegate onGetUploadURL:nil atTime:point duration:length option:type tag:tag];
        });
        return;
    }
    NewCmdBuffer(tmp)
    vdb_cmd_GetUploadUrl_t* cmd = (vdb_cmd_GetUploadUrl_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetUploadUrl;
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    cmd->b_playlist = NO;//(domain >= VDBDomain_Playlist1) && (domain <= VDBDomain_PlaylistEnd);
    cmd->header.cmd_tag = tag; //user_data
    unsigned long long tt = point * 1000;
    cmd->clip_time_ms_hi = tt >> 32;
    cmd->clip_time_ms_lo = (tt & 0x0ffffffff);
    cmd->length_ms =  uint32_t(length*1000);
    cmd->upload_opt = type;
    if (vdbid != nil) {
        void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetUploadUrl_t));
        NSData* data = [vdbid getStructVDBID];
        memcpy(iddata, [data bytes], [data length]);
    }
    NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
    [self sendData:tmp];
}
//for album or mark
- (void)removeClip:(int)clipid inDomain:(WLVDBDomain)domain withID:(WLVDBID *)vdbid {
    NewCmdBuffer(tmp)
    vdb_cmd_DeleteClip_t* cmd = (vdb_cmd_DeleteClip_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_DeleteClip;
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    if (vdbid != nil) {
        void *iddata = (void*)(tmp + sizeof(vdb_cmd_DeleteClip_t));
        NSData* data = [vdbid getStructVDBID];
        memcpy(iddata, [data bytes], [data length]);
    }
    NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
    [self sendData:tmp];
}

- (void)markClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)sec withID:(WLVDBID *)vdbid {
    NewCmdBuffer(tmp)
    vdb_cmd_MarkClip_t* cmd = (vdb_cmd_MarkClip_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_MarkClip;
    cmd->header.cmd_tag = 0;
    cmd->header.user1 = 0;
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    unsigned long long tt = point * 1000;
    cmd->start_time_ms_hi = (tt >> 32);
    cmd->start_time_ms_lo = (tt & 0x0ffffffff);
    tt += sec * 1000;
    cmd->end_time_ms_hi = tt >> 32;
    cmd->end_time_ms_lo = (tt & 0x0ffffffff);
    if (vdbid != nil) {
        void *iddata = (void*)(tmp + sizeof(vdb_cmd_MarkClip_t));
        NSData* data = [vdbid getStructVDBID];
        memcpy(iddata, [data bytes], [data length]);
    }
    NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
    [self sendData:tmp];
}

//for playlist
- (void)getAllPlaylists {

    NewCmdBuffer(tmp)
    vdb_cmd_GetAllPlaylists_t* cmd = (vdb_cmd_GetAllPlaylists_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetAllPlaylists;
    cmd->flags = 0;
    [self sendData:tmp];
}

- (void)clearPlaylist:(WLVDBDomain)domain {

    NewCmdBuffer(tmp)
    vdb_cmd_ClearPlaylist_t* cmd = (vdb_cmd_ClearPlaylist_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_ClearPlaylist;
    cmd->list_type = domain;
    [self sendData:tmp];
}

- (void)getPlaylistIndexPic:(WLVDBDomain)domain tag:(int)tag {
    NewCmdBuffer(tmp)
    vdb_cmd_GetPlaylistIndexPicture_t* cmd = (vdb_cmd_GetPlaylistIndexPicture_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetPlaylistIndexPicture;
    cmd->header.cmd_tag = tag;
    cmd->list_type = domain;
    cmd->flags = 0;
    [self sendData:tmp];
}

- (void)moveClip:(int)clipid inPlaylist:(WLVDBDomain)domain to:(int)newpos {
    NewCmdBuffer(tmp)
    vdb_cmd_MoveClip_t* cmd = (vdb_cmd_MoveClip_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_MoveClip;
    cmd->clip_type      = domain;
    cmd->clip_id        = clipid;
    cmd->new_clip_pos   = newpos;
    [self sendData:tmp];
}

- (void)insertClip:(int)clipid FromDomain:(WLVDBDomain)domain To:(int)playlistindex from:(double)point length:(double)sec {
    NewCmdBuffer(tmp)
    vdb_cmd_InsertClip_t* cmd = NULL;
    if (vdbVersionMinor >= 6 && vdbVersionMajor >= 1) {
        vdb_cmd_InsertClipEx_t* cmdex = (vdb_cmd_InsertClipEx_t*)tmp;
        cmd = &(cmdex->inherited);
        cmd->header.cmd_code = VDB_CMD_InsertClipEx;
    } else {
        cmd = (vdb_cmd_InsertClip_t*)tmp;
        cmd->header.cmd_code = VDB_CMD_InsertClip;
    }
    cmd->header.cmd_tag = 0;
    cmd->header.user1 = 0;
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    unsigned long long tt = point * 1000;
    cmd->start_time_ms_hi = (tt >> 32);
    cmd->start_time_ms_lo = (tt & 0x0ffffffff);
    tt += sec * 1000;
    cmd->end_time_ms_hi = tt >> 32;
    cmd->end_time_ms_lo = (tt & 0x0ffffffff);
    cmd->list_type              = playlistindex + CLIP_TYPE_PLIST0;
    cmd->list_pos               = -1;
    [self sendData:tmp];
}

- (void)getRawDataForClip:(int)clipid inDomain:(WLVDBDomain)domain Attime:(double)point withID:(WLVDBID *)vdbid {
    NewCmdBuffer(tmp)
    vdb_cmd_GetRawData_t* cmd = (vdb_cmd_GetRawData_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetRawData;
    cmd->header.user1 = 0;
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    unsigned long long tt = point * 1000;
    cmd->clip_time_ms_hi = tt >> 32;
    cmd->clip_time_ms_lo = (tt & 0x0ffffffff);
    cmd->data_types = (1<<kRawData_GPS) | (1<<kRawData_OBD) | (1<<kRawData_ACC);
    if (vdbid != nil) {
        void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetRawData_t));
        NSData* data = [vdbid getStructVDBID];
        memcpy(iddata, [data bytes], [data length]);
    }
    [self sendData:tmp];
}

-(void)getRawDataWithACC:(BOOL)acc GPS:(BOOL)gps OBD:(BOOL)obd forClip:(int)clipId inDomain:(WLVDBDomain)domain atTime:(double)point tag:(uint32_t)tag withVDBId:(WLVDBID *)vdbId {
    NewCmdBuffer(tmp)
    vdb_cmd_GetRawData_t* cmd = (vdb_cmd_GetRawData_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetRawData;
    cmd->header.cmd_tag = tag;
    cmd->header.user1 = 0;
    cmd->clip_type = domain;
    cmd->clip_id = clipId;
    unsigned long long tt = point * 1000;
    cmd->clip_time_ms_hi = tt >> 32;
    cmd->clip_time_ms_lo = (tt & 0x0ffffffff);
    cmd->data_types = (gps<<kRawData_GPS) | (obd<<kRawData_OBD) | (acc<<kRawData_ACC);
    if (vdbId != nil) {
        void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetRawData_t));
        NSData* data = [vdbId getStructVDBID];
        memcpy(iddata, [data bytes], [data length]);
    }
    [self sendData:tmp];
}

- (void)getLiveRawDataWithACC:(BOOL)acc GPS:(BOOL)gps OBD:(BOOL)obd {
    NewCmdBuffer(tmp)
    vdb_cmd_SetRawDataOption_t* cmd = (vdb_cmd_SetRawDataOption_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_SetRawDataOption;
    cmd->header.user1 = 0;
    cmd->data_types = 0;
    if (acc) {
        cmd->data_types += (1<<kRawData_ACC);
    }
    if (gps) {
        cmd->data_types += (1<<kRawData_GPS);
    }
    if (obd) {
        cmd->data_types += (1<<kRawData_OBD);
    }
    NSLog(@"VDBClient Send CMD:%d", cmd->header.cmd_code);
    [self sendData:tmp];
}
- (void)setOptionsNoDelay {
    NewCmdBuffer(tmp0)
    vdb_cmd_SetOptions_t* cmd0 = (vdb_cmd_SetOptions_t*)tmp0;
    cmd0->header.cmd_code = VDB_CMD_SetOptions;
    cmd0->option = VDB_OPTION_TCP_NODELAY;
    cmd0->params[0] = 1;
    NSLog(@"VDBClient Send CMD:%d", cmd0->header.cmd_code);
    [self sendData:tmp0];
}

- (void)getLiveDMSData:(BOOL)enable {
    NewCmdBuffer(tmp)
    vdb_cmd_SetOptions_t* cmd = (vdb_cmd_SetOptions_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_SetOptions;
    cmd->option = VDB_OPTION_NEED_EXTRA_RAW_DATA;
    cmd->params[0] = enable ? MAKE_FOURCC_STR("DMS0") : 0;
    NSLog(@"getLiveDMSData Send CMD:%d enable: %s, param: %x",
          cmd->header.cmd_code, enable ? "YES"  : "NO", cmd->params[0]);
    [self sendData:tmp];
    cmd->params[0] = enable ? MAKE_FOURCC_STR("DMS1") : 0;
    NSLog(@"getLiveDMSData Send CMD:%d enable: %s, param: %x",
          cmd->header.cmd_code, enable ? "YES"  : "NO", cmd->params[0]);
    [self sendData:tmp];
}

- (void)getRawDataBlockForClip:(int)clipid inDomain:(WLVDBDomain)domain dataType:(int)type Attime:(double)point length:(double)sec tag:(int16_t)tag userData:(int)userData userData2:(int)userData2 forCache:(BOOL)bcache withID:(WLVDBID *)vdbid {
    NewCmdBuffer(tmp)
    vdb_cmd_GetRawDataBlock_t* cmd = (vdb_cmd_GetRawDataBlock_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetRawDataBlock;
    cmd->header.cmd_tag = type << 28 | (bcache?(1<<27):0) | (domain << 16) | tag;
    cmd->header.user1 = userData;
    cmd->header.user2 = userData2;
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    unsigned long long tt = point * 1000;
    cmd->clip_time_ms_hi = tt >> 32;
    cmd->clip_time_ms_lo = (tt & 0x0ffffffff);
    cmd->data_type = type;
    cmd->length_ms = (int)(sec * 1000);
    if (vdbid != nil) {
        void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetRawDataBlock_t));
        NSData* data = [vdbid getStructVDBID];
        memcpy(iddata, [data bytes], [data length]);
    }
    [self sendData:tmp];
}

- (void)getExtraRawDataForClip:(int)clipid inDomain:(WLVDBDomain)domain atTime:(double)point withIndexes:(int32_t)types withID:(WLVDBID *)vdbid {
    NewCmdBuffer(tmp)
    vdb_cmd_GetExtraRawData_t* cmd = (vdb_cmd_GetExtraRawData_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetExtraRawData;
    cmd->header.user1 = 0;
    cmd->clip_type = domain;
    cmd->clip_id = clipid;
    unsigned long long tt = point * 1000;
    cmd->clip_time_ms_hi = tt >> 32;
    cmd->clip_time_ms_lo = (tt & 0x0ffffffff);
    if (types != 0) {
        cmd->data_types = (int32_t)types;
        cmd->all_data_types = 0;
    } else {
        cmd->data_types = 0;
        cmd->all_data_types = 1;
    }
    if (vdbid != nil) {
        void *iddata = (void*)(tmp + sizeof(vdb_cmd_GetRawDataBlock_t));
        NSData* data = [vdbid getStructVDBID];
        memcpy(iddata, [data bytes], [data length]);
    }
//    NSLog(@"VDBClient Send ExtraRawData CMD:%d, time: %0.3f", cmd->header.cmd_code, point);
    [self sendData:tmp];
}

- (void)setIsReady:(BOOL)rdy {
    isReady = rdy;
    [_clipsDelegate onVDBState:rdy];
}

- (void)onConnected {
    //do nothing, return in VDB_CMD_GetVersionInfo
    [self setOptionsNoDelay];
}
- (void)sendHeartBeat {
//    NSLog(@"CameraVDBClient sendHeartBeat");
    NewCmdBuffer(tmp)
    vdb_cmd_GetVersionInfo_t* cmd = (vdb_cmd_GetVersionInfo_t*)tmp;
    cmd->header.cmd_code = VDB_CMD_GetVersionInfo;
    [self sendData:tmp];
}

@end
