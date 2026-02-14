//
//  WLCameraVDBClipsAgent.m
//  Hachi
//
//  Created by gliu on 16/4/15.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import "WLCameraVDBClipsAgent.h"

#import "vdb_cmd.h"
#import "vdb_ios_types.h"
#import "Define+FrameworkInternal.h"
#import "WLCameraVDBClient+FrameworkInternal.h"
#import "WLVDBClip+FrameworkInternal.h"

@interface WLCameraVDBClipsAgent ()
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, strong) NSMutableArray *bookmarkClips;
@property (nonatomic, strong) NSMutableArray *loopClips;
@property (nonatomic, strong) NSMutableArray *manualClips;
@end

@implementation WLCameraVDBClipsAgent

- (id)initWithVDB:(WLCameraVDBClient*)pVdb {
    self = [super init];
    if (self) {
        _vdb = pVdb;
        _bookmarkClips  = [[NSMutableArray alloc] init];
        _manualClips    = [[NSMutableArray alloc] init];
        _loopClips      = [[NSMutableArray alloc] init];
        _delegates      = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc {
    if (_delegates.count > 0) {
        [_delegates removeAllObjects];
    }
}

- (void)addDelegate:(id<WLCameraVDBClipsAgentDelegate>)dele {
    if (![_delegates containsObject:dele]) {
        [_delegates addObject:dele];
    }
}
- (void)removeDelegate:(id<WLCameraVDBClipsAgentDelegate>)dele {
    if ([_delegates containsObject:dele]) {
        [_delegates removeObject:dele];
    }
}
- (NSArray<WLVDBClip*>*)listOfType:(WLClipListType)type {
    NSMutableArray* arr = nil;
    switch (type) {
        case WLClipListTypeBookMark:
            arr = _bookmarkClips;
            break;
        case WLClipListTypeManual:
            arr = _manualClips;
            break;
        case WLClipListTypeLoop:
            arr = _loopClips;
            break;
        default:
            break;
    }
    return arr;
}
- (WLVDBClip*)bufferedClipForMarkClip:(WLVDBClip*)clip {
    for (WLVDBClip* c in _manualClips) {
        if (c.realClipID == clip.realClipID) {
            return c;
        }
    }
    for (WLVDBClip* c in _loopClips) {
        if (c.realClipID == clip.realClipID) {
            return c;
        }
    }
    return nil;
}
- (WLVDBClip*)clipForMarkClipWithID:(int)clipID {
    for (WLVDBClip* c in _bookmarkClips) {
        if (c.clipID == clipID) {
            return c;
        }
    }
    return nil;
}

- (void)refreshVdbState {
    [self onVDBState:NO];
    [self onVDBState:YES];
}

-(void)onVDBState:(BOOL)bReady {
    for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
        [dele onVDBReady:bReady];
    }
    if (bReady) {
        [_vdb getVDBClipsforDomain:VDBDomain_Mark tag:0];
        [_vdb getVDBClipsforDomain:VDBDomain_Album tag:0];
    } else {
        [_bookmarkClips removeAllObjects];
        [_manualClips removeAllObjects];
        [_loopClips removeAllObjects];
    }
}
-(void)onGetClips:(NSArray*)clips inDomain:(WLVDBDomain)domain {
    switch (domain) {
        case VDBDomain_Mark: {
            for (WLVDBClip* clip in clips) {
                BOOL exist = NO;
                for (WLVDBClip* c in _bookmarkClips) {
                    if (c.clipID == clip.clipID) {
                        exist = YES;
                        break;
                    }
                }
                if (!exist) {
                    [_bookmarkClips addObject:clip];
                }
            }
            NSLog(@"get VBD infor[Mark]: %ld", (unsigned long)[clips count]);
        }
            break;
        case VDBDomain_Album: {
            [self onGetBufferedClips:clips];
        }
            break;
        default:
            break;
    }
    for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
        switch (domain) {
            case VDBDomain_Mark:
                [dele onClipListLoaded:WLClipListTypeBookMark];
                break;
            case VDBDomain_Album:
                [dele onClipListLoaded:WLClipListTypeManual];
                [dele onClipListLoaded:WLClipListTypeLoop];
                break;
            default:
                break;
        }
    }
}
-(void)onClipRemove:(int)clipid inDomain:(WLVDBDomain)domain {
    switch (domain) {
        case VDBDomain_Mark: {
            for (WLVDBClip* clip in _bookmarkClips) {
                if (clip.clipID == clipid) {
                    [_bookmarkClips removeObject:clip];
                    for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
                        [dele onRemoveClip:clip fromList:WLClipListTypeBookMark];
                    }
                    break;
                }
            }
        }
            break;
        case VDBDomain_Album: {
            BOOL done = NO;
            for (WLVDBClip* clip in _manualClips) {
                if (clip.clipID == clipid) {
                    [_manualClips removeObject:clip];
                    for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
                        [dele onRemoveClip:clip fromList:WLClipListTypeManual];
                    }
                    done = YES;
                    break;
                }
            }
            if (!done) {
                for (WLVDBClip* clip in _loopClips) {
                    if (clip.clipID == clipid) {
                        [_loopClips removeObject:clip];
                        for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
                            [dele onRemoveClip:clip fromList:WLClipListTypeLoop];
                        }
                        break;
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}
-(void)onClipUpdate:(vdb_msg_ClipInfo_t*)infor {
    WLVDBClip* clip = nil;
    WLClipListType type = WLClipListTypeLoop;
    switch (infor->action) {
        case CLIP_ACTION_FINISHED:
        case CLIP_ACTION_CHANGED: {
            switch (infor->clip_type) {
                case CLIP_TYPE_BUFFER:
                case CLIP_TYPE_MARKED: {
//                    break; // TODO: disable update clip info for now
                    clip = [self clipWithID:infor->clip_id withTye:infor->clip_type];
                    if (clip) {
                        [clip updateClip:infor];
                    }if (infor->clip_type == CLIP_TYPE_MARKED) {
                        type = WLClipListTypeBookMark;
                    } else {
                        if (clip.isManual) {
                            type = WLClipListTypeManual;
                        }
                    }
                }
                    break;
                default:
                    break;
            }
            for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
                [dele onUpdateClip:clip fromList:type];
            }
        }
            break;
        case CLIP_ACTION_CREATED: {
            switch (infor->clip_type) {
                case CLIP_TYPE_BUFFER:
                case CLIP_TYPE_MARKED: {
                    clipInfor info;
                    info.clip_id = infor->clip_id;
                    info.clip_date = [NSDate new].timeIntervalSince1970;
                    info.clip_duration_ms = infor->clip_duration_ms;
                    info.clip_start_time_ms_lo = infor->clip_start_time_ms_lo;
                    info.clip_start_time_ms_hi = infor->clip_start_time_ms_hi;
                    info.num_streams = infor->num_streams;
                    info.flags = infor->flags;
                    NSMutableData* data = [[NSMutableData alloc] initWithBytes:&info length:sizeof(info)];
                    [data appendBytes:infor->stream_info length:sizeof(avf_stream_attr_t)*MAX_VDB_STREAMS];
                    clip = [[WLVDBClip alloc] initWithInforData:data type:infor->clip_type needDewarp:self.vdb.needDewarp];
                    if (infor->clip_type == CLIP_TYPE_MARKED) {
                        [_bookmarkClips addObject:clip];
                        type = WLClipListTypeBookMark;
                    } else {
                        if (clip.isManual) {
                            [_manualClips addObject:clip];
                            type = WLClipListTypeManual;
                        } else {
                            [_loopClips addObject:clip];
                            type = WLClipListTypeLoop;
                        }
                    }
                    [_vdb getVDBClipInfoForClip:clip.clipID inDomain:clip.clipType];
                }
                    break;
                default:
                    break;
            }

            //TODO: find a better way to set the value.
            NSObject *WLCameraDevice = (NSObject *)_vdb.connectionDelegate;
            if ([WLCameraDevice respondsToSelector:NSSelectorFromString(@"isUpsideDown")]) {
                BOOL isUpsideDown = [[WLCameraDevice valueForKeyPath:@"isUpsideDown"] boolValue];
                clip.isRotated = isUpsideDown;
            } else {
                NSLog(@"Failed to set VDBClip's 'isRotated' property, as CameraDevice's 'isUpsideDown' key path is not existed!");
            }

            for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
                [dele onNewClip:clip toList:type];
            }
        }
            break;
        default:
            break;
    }
}
-(void)onGetClipInfo:(WLVDBClip*)clip for:(int)clipid {
    if (clip.clipType == CLIP_TYPE_MARKED) {
        NSUInteger index = -1;
        for (WLVDBClip* c in _bookmarkClips) {
            if (c.clipID == clipid) {
                index = [_bookmarkClips indexOfObject:c];
                if (index < _bookmarkClips.count) {

                    // When the camera installation mode(`isUpsideDown`property) change, the corresponding info not exists in the returned WLVDBClip info.
                    if (c.isLive && c.isRotated) {
                        clip.isRotated = true;
                    }

                    [_bookmarkClips replaceObjectAtIndex:index withObject:clip];
                    for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
                        [dele onClipListLoaded:WLClipListTypeBookMark];
                    }
                }
                return;
            }
        }
    }

    if (clip.clipType == CLIP_TYPE_BUFFER) {
        NSUInteger index = -1;
        for (WLVDBClip* c in _loopClips) {
            if (c.clipID == clipid) {
                index = [_loopClips indexOfObject:c];
                if (index < _loopClips.count) {

                    // When the camera installation mode(`isUpsideDown`property) change, the corresponding info not exists in the returned WLVDBClip info.
                    if (c.isLive && c.isRotated) {
                        clip.isRotated = true;
                    }

                    [_loopClips replaceObjectAtIndex:index withObject:clip];
                    for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
                        [dele onClipListLoaded:WLClipListTypeLoop];
                    }
                }
                return;
            }
        }
        for (WLVDBClip* c in _manualClips) {
            if (c.clipID == clipid) {
                index = [_manualClips indexOfObject:c];
                if (index < _loopClips.count) {

                    // When the camera installation mode(`isUpsideDown`property) change, the corresponding info not exists in the returned WLVDBClip info.
                    if (c.isLive && c.isRotated) {
                        clip.isRotated = true;
                    }

                    [_manualClips replaceObjectAtIndex:index withObject:clip];
                    for (id<WLCameraVDBClipsAgentDelegate> dele in _delegates) {
                        [dele onClipListLoaded:WLClipListTypeManual];
                    }
                }
                return;
            }
        }
    }
}

- (NSString*)getRecordConfigFromClip:(int32_t)clipID inDomain:(WLVDBDomain)clip_type {
    NSString* recordConfig = @"";
    if (clip_type == CLIP_TYPE_MARKED) {
        for (WLVDBClip* c in _bookmarkClips) {
            if (c.clipID == clipID) {
                recordConfig = [NSString stringWithString:c.recordConfig];
            }
        }
    }

    if (clip_type == CLIP_TYPE_BUFFER) {
        for (WLVDBClip* c in _loopClips) {
            if (c.clipID == clipID) {
                recordConfig = [NSString stringWithString:c.recordConfig];
            }
        }
    }
    return recordConfig;
}
#pragma mark -- private
- (void)onGetBufferedClips:(NSArray*)clips {
    for (WLVDBClip* clip in clips) {
        if (clip.isManual) {
            BOOL exist = NO;
            for (WLVDBClip* c in _manualClips) {
                if (c.clipID == clip.clipID) {
                    exist = YES;
                    break;
                }
            }
            if (!exist) {
                [_manualClips addObject:clip];
            }
        } else {
            BOOL exist = NO;
            for (WLVDBClip* c in _loopClips) {
                if (c.clipID == clip.clipID) {
                    exist = YES;
                    break;
                }
            }
            if (!exist) {
                [_loopClips addObject:clip];
            }
        }
    }
    NSLog(@"get VBD infor[Manual]: %ld", (unsigned long)[_manualClips count]);
    NSLog(@"get VBD infor[Loop]: %ld", (unsigned long)[_loopClips count]);
}
    
- (WLVDBClip*)clipWithID:(int)clipID withTye:(WLVDBDomain)type {
    WLVDBClip* clip = nil;
    switch (type) {
        case VDBDomain_Album: {
            for (WLVDBClip* c in _loopClips) {
                if (c.clipID == clipID) {
                    clip = c;
                    break;
                }
            }
            if (clip == nil) {
                for (WLVDBClip* c in _manualClips) {
                    if (c.clipID == clipID) {
                        clip = c;
                        break;
                    }
                }
            }
        }
            break;

        case VDBDomain_Mark: {
            for (WLVDBClip* c in _bookmarkClips) {
                if (c.clipID == clipID) {
                    clip = c;
                    break;
                }
            }
        }
            break;
        default:
            break;
    }
    return clip;
}
@end
