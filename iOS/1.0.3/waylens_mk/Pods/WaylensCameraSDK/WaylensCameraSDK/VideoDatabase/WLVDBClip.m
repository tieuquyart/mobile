//
//  WLVDBClip.m
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/29.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import "WLVDBClip.h"
#include "vdb_ios_types.h"
#import "Define+FrameworkInternal.h"

#define maxstremsInClip 5

@implementation WLVDBID {
    int id_size;
    NSData *obj;
}

-(id)initWithSize:(int)size data:(NSData*)data
{
    self = [super init];
    if (self) {
        id_size = size;
        obj = [NSData dataWithData:data];
    }
    return self;
}
-(NSData*) getStructVDBID
{
    NSMutableData* data = [NSMutableData dataWithBytes:&id_size length:sizeof(uint32_t)];
    [data appendData:obj];
    return data;
}

@end

@interface WLVDBClip() {
    clipInforEx _info;
    avf_stream_attr_t _streamInfor[maxstremsInClip];

    UInt32 ref_clip_date;
    int32_t gmtoff;
    UInt32 real_clip_id;

    int32_t attr;

    NSString* uuid;

    //viechle identify number
    NSString* vin;

    WLVDBID* vdbID;

    vdb_ack_GetClipExtent_t clipExtent;

    VIDEO_EVENT_TYPE _eventType;
    double _eventDate;
    DMS_STATUS _dmsType;
    double _dmsDate;
    int videoType[8];

    NSMutableArray<NSString*>* streamResolutions;
}
@property (nonatomic, assign) int dmsIndex; // internal raw data index
@property (nonatomic, assign) DMS_STATUS dmsType;
@property (nonatomic, assign) double dmsDate;
@property (nonatomic, assign) ADAS_STATUS adasType;
@property (nonatomic, assign) double adasDate;
@end

@implementation WLVDBClip

- (id)initWithInforData:(NSData*)clipdata type:(int32_t)cliptype needDewarp:(BOOL)dewarp {
    self = [super init];
    if(self) {
        uuid = @"";
        vin = @"";
        ref_clip_date = 0;
        gmtoff = 0;
        real_clip_id = 0;
        attr = 0;
        vdbID = nil;
        _eventType = VIDEO_EVENT_TYPE_NULL;
        _eventDate = 0;
        _needDewarp = dewarp;
        _dmsIndex = -1;
        _dmsType = DMS_unknown;
        _dmsDate = 0;
        _adasType = ADAS_unknown;
        _adasDate = 0;
        _recordConfig = @"";
        streamResolutions = [[NSMutableArray alloc] init];
        memset(&clipExtent, 0, sizeof(clipExtent));
        memset(videoType, 0, 8*sizeof(int));
        [self updateInfoData:clipdata type:(int32_t)cliptype];
    }
    return self;
}
- (id)initWithInforExData:(NSData*)clipdata needDewarp:(BOOL)dewarp {
    self = [super init];
    if(self) {
        uuid = @"";
        vin = @"";
        ref_clip_date = 0;
        gmtoff = 0;
        real_clip_id = 0;
        vdbID = nil;
        _eventType = VIDEO_EVENT_TYPE_NULL;
        _eventDate = 0;
        _needDewarp = dewarp;
        _dmsIndex = -1;
        _dmsType = DMS_unknown;
        _adasType = ADAS_unknown;
        _dmsDate = 0;
        _adasDate = 0;
        _recordConfig = @"";
        streamResolutions = [[NSMutableArray alloc] init];
        [self updateInfoEXData:clipdata];
    }
    return self;
}
- (void)setVDBID:(const char*)vdbidData {
    if (vdbidData) {
        vdb_id_t* vdbid = (vdb_id_t*)(vdbidData);
        if (vdbid->id_size != 0 ) {
            int idsize = ((vdbid->id_size + 3)>>2)<<2;
            vdbID = [[WLVDBID alloc]initWithSize:vdbid->id_size
                                          data:[NSData dataWithBytes:vdbidData + sizeof(vdb_id_t) length:idsize]];
        }
    }
}

- (int)clipID {
    return _info.inherited.clip_id;
}
- (int)clipType {
    return _info.clip_type;
}
- (double)startTime {
    return sTimeFloat(_info.inherited.clip_start_time_ms_hi, _info.inherited.clip_start_time_ms_lo);
}
- (double)duration {
    return _info.inherited.clip_duration_ms * 1.0 / 1000;
}
- (double)startDate {
    return /*_starttime +*/ _info.inherited.clip_date;
}
- (BOOL)isManual {
    return (attr & CLIP_ATTR_MANUALLY) != 0;
}
- (BOOL)isNoAutoDel {
    return (attr & CLIP_ATTR_NO_AUTO_DELETE) != 0;
}
- (BOOL)isLive {
    return (attr & CLIP_ATTR_LIVE) != 0;
}
- (int)streamNum {
    return _info.inherited.num_streams;
}
- (NSArray<NSString*>*) resolutions {
    return [[NSArray alloc] initWithArray:streamResolutions];
}
-(WLVDBID*)vdbID {
    return vdbID;
}
- (NSString*)uuid {
    return uuid;
}
- (NSString*)vin {
    return vin;
}
- (int)gmtoff {
    return gmtoff;
}
- (int)realClipID {
    return real_clip_id;
}
-(VIDEO_EVENT_TYPE)eventType {
    return _eventType;
}
-(double)eventDate {
    return _eventDate;
}


- (void)updateClip:(vdb_msg_ClipInfo_t*)info {
    _info.inherited.num_streams = info->num_streams;
    for(int i = 0; i < _info.inherited.num_streams; i++) {
        memcpy(&_streamInfor[i], &(info->stream_info[i]), sizeof(avf_stream_attr_t));
    }
    attr = info->flags;
    if (info->action == CLIP_ACTION_FINISHED) {
        attr &= ~(CLIP_ATTR_LIVE);
    }
//    if (info->action & CLIP_ACTION_CHANGED) {
        _info.inherited.clip_date = info->clip_date;
        _info.inherited.clip_start_time_ms_hi = info->clip_start_time_ms_hi;
        _info.inherited.clip_start_time_ms_lo = info->clip_start_time_ms_lo;
        _info.inherited.clip_duration_ms = info->clip_duration_ms;
//    }

}

- (double)getFramerateForStream:(int)index {
    double framerate = 0;
    switch (_streamInfor[index].video_framerate) {
        case FrameRate_12_5:
            framerate = 12.5;
            break;
        case FrameRate_6_25:
            framerate = 6.25;
            break;
        case FrameRate_23_976:
            framerate = 23.976;
            break;
        case FrameRate_24:
            framerate = 24;
            break;
        case FrameRate_25:
            framerate = 25;
            break;
        case FrameRate_29_97:
            framerate = 29.97;
            break;
        case FrameRate_30:
            framerate = 30;
            break;
        case FrameRate_50:
            framerate = 50;
            break;
        case FrameRate_59_94:
            framerate = 59.94;
            break;
        case FrameRate_60:
            framerate = 60;
            break;
        case FrameRate_120:
            framerate = 120;
            break;
        case FrameRate_240:
            framerate = 240;
            break;
        case FrameRate_20:
            framerate = 20;
            break;
        case FrameRate_15:
            framerate = 15;
            break;
        case FrameRate_14_985:
            framerate = 14.985;
            break;

        default:
            break;
    }
    return framerate;
}
- (int)getResolutionForStream:(int)index {
    return (int)(_streamInfor[index].video_width << 16 | _streamInfor[index].video_height);
}
- (BOOL)isMP4ForStream:(int)index {
    return videoType[index] == VIDEO_TYPE_MP4;
}

- (void)setClipExtent:(vdb_ack_GetClipExtent_t*)clipex {
    memcpy(&clipExtent, clipex, sizeof(clipExtent));
}
- (double)getRealStartTime {
    return sTimeFloat(clipExtent.min_clip_start_time_ms_hi, clipExtent.min_clip_start_tims_ms_lo);
}
- (double)getRealEndTime {
    return sTimeFloat(clipExtent.max_clip_end_time_ms_hi, clipExtent.max_clip_end_time_ms_lo);
}

-(void)setNewTimeRangeFrom:(double)from To:(double)to {
    unsigned long long tt = from * 1000;
    _info.inherited.clip_start_time_ms_hi = tt >> 32;
    _info.inherited.clip_start_time_ms_lo = tt & 0x0ffffffff;
    _info.inherited.clip_duration_ms = (to - from) * 1000;
}

- (int)flags {
    return _info.inherited.flags;
}

- (NSString*)getInforAsString {
    //float currentPoint = sub;
    NSDate *now = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: now];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.startDate - interval];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSString* startDate = [NSString stringWithFormat:@"%d/%02d/%02d %d:%02d:%02d", (int)components.year, (int)components.month, (int)components.day, (int)components.hour, (int)components.minute, (int)components.second];

    return [NSString stringWithFormat:
            @"%@:%@\n%@:%7.1f%@" //@:%d%@
            ,NSLocalizedString(@"From", @"clip start time"), startDate
            ,NSLocalizedString(@"Clip Length", @"clip length")
            ,self.duration, @"S"];
    //,@"Clip Size",,@"MB"];
}

- (avf_stream_attr_t*)getStreamInfor:(int)index {
    return &_streamInfor[index];
}
#pragma mark - private
-(void)updateInfoData:(NSData*)clipdata type:(int32_t)cliptype {
    char *pdata = (char *)[clipdata bytes];
    memcpy(&_info, pdata, sizeof(clipInfor));
    _info.clip_type = cliptype;
    _info.extra_size = 0;
    for(int i = 0; i < _info.inherited.num_streams; i++) {
        memcpy(&_streamInfor[i], pdata + sizeof(clipInfor) + i*sizeof(avf_stream_attr_t), sizeof(avf_stream_attr_t));
    }
    attr = _info.inherited.flags;
}

-(void)updateInfoEXData:(NSData*)clipdata {
    char *pdata = (char *)[clipdata bytes];
    memcpy(&_info, pdata, sizeof(clipInfor));
    _info.extra_size = 0;
    int offset = sizeof(clipInfor);
    for(int i = 0; i < _info.inherited.num_streams; i++) {
        memcpy(&_streamInfor[i], pdata + sizeof(clipInfor) + i*sizeof(avf_stream_attr_t), sizeof(avf_stream_attr_t));
        offset += sizeof(avf_stream_attr_t);
    }
    _info.clip_type = *((int32_t*)(pdata + offset));
    offset += 4;
    _info.extra_size = *((int32_t*)(pdata + offset));
    offset += 4;
    if (_info.inherited.flags & GET_CLIP_EXTRA) {
        char suuid[UUID_LEN+1];
        memset(suuid, 0, UUID_LEN+1);
        memcpy(suuid, ((char*)pdata) + offset, UUID_LEN);
        uuid = [NSString stringWithFormat:@"%s", suuid];
        offset += UUID_LEN;
        ref_clip_date = *((UInt32*)(pdata + offset));
        offset += 4;
        gmtoff = *((int32_t*)(pdata + offset));
        offset += 4;
        real_clip_id = *((UInt32*)(pdata + offset));
        offset += 4;
    }

    if (_info.inherited.flags & GET_CLIP_DESC) {
        for (;;) {
            uint32_t fcc = *((uint32_t*)(pdata + offset));
            offset += 4;
            if (fcc == 0) break;
            uint32_t data_size = *((uint32_t*)(pdata + offset));
            offset += 4;

            if (fcc == MAKE_FOURCC_STR("0NIV")) {
                uint8_t data[data_size + 1];
                memset(data, 0, data_size+1);
                memcpy(data, ((char*)pdata) + offset, data_size);
                vin = [NSString stringWithFormat:@"%s", data];
            } else if (fcc == MAKE_FOURCC_STR("CNIV")) {
                uint8_t data[data_size + 1];
                memset(data, 0, data_size+1);
                memcpy(data, ((char*)pdata) + offset, data_size);
                vin_config_info_t* cfg = (vin_config_info_t*)data;
                //_isRotated = cfg->mirror_vertical && cfg->mirror_horizontal;
                _isHDR = (cfg->hdr_mode != 0);
            } else if (fcc == MAKE_FOURCC_STR("ISYS")) {
                uint8_t data[data_size + 1];
                memset(data, 0, data_size+1);
                memcpy(data, ((char*)pdata) + offset, data_size);
                if (data_size > 32) {
                    ;
                }
                int sysi_offset = 0;
                for (;;) {
                    sys_info_t* sysinfo = (sys_info_t*)(data + sysi_offset);
                    uint32_t item_size = *((uint32_t*)(data + sizeof(sys_info_t)));
                    if (sysinfo->fcc == MAKE_FOURCC_STR("ITTA")) {
                        NSString* atti = [NSString stringWithFormat:@"%s", (char*)sysinfo + sizeof(sys_info_t) + 4];
                        _isRotated = [atti isEqualToString:@"upsidedown"];
                    }
                    if (sysinfo->fcc == MAKE_FOURCC_STR(" N/S")) {
                        _sn = [NSString stringWithFormat:@"%s", (char*)sysinfo + sizeof(sys_info_t) + 4];
                        if (_sn.length > item_size) {
                            _sn = [_sn substringWithRange:NSMakeRange(0, item_size)];
                        }
                        if (_sn.length >= 8) {
                            if ([_sn hasPrefix:@"2"]) { // TW02
                                _needDewarp = true;
                            } else {
                                _needDewarp = false;
                            }
                        }
                    }
                    if (sysinfo->fcc == MAKE_FOURCC_STR("GFCR")) {
                        _recordConfig = [NSString stringWithFormat:@"%s", (char*)sysinfo + sizeof(sys_info_t) + 4];
                        ;
                    }
                    sysi_offset += sizeof(sys_info_t) + 4 + item_size;
                    if (sysi_offset > data_size + sizeof(sys_info_t) + 4) {
                        break;
                    }
                }
            }
            offset += ((data_size + 3) / 4) * 4;
        }
    }
    if (_info.inherited.flags & GET_CLIP_ATTR) {
        attr = *((UInt32*)(pdata + offset));
        offset += 4;
    }
    if(_info.inherited.flags & GET_CLIP_SCENE_DATA) {
        uint32_t totalSize = *((uint32_t*)(pdata + offset));
        const char* scenedata = nil;
        const char* pscenedata = pdata+offset;
        for(int i = 0; i < clipdata.length-offset-4; ++i) {
            uint32_t fcc = *((uint32_t*)(pscenedata+i));
            if(fcc == MAKE_FOURCC_STR("Park")) {
                scenedata = pscenedata+i;
                break;
            }
            if(fcc == MAKE_FOURCC_STR("EVNT")) {
                scenedata = pscenedata+i;
                break;
            }
            if (fcc == MAKE_FOURCC_STR("DMSE")) {
                scenedata = pscenedata+i;
                break;
            }
            if (fcc == MAKE_FOURCC_STR("ADAS")) {
                scenedata = pscenedata+i;
                break;
            }
        }
        offset += totalSize + sizeof(uint32_t);

        if(scenedata == NULL) {
            return;
        }
        uint32_t fcc = *((uint32_t*)(scenedata));
        if (fcc == MAKE_FOURCC_STR("Park")) {
            ParkSceneData data;
            memset(&data, 0, sizeof(ParkSceneData));
            memcpy(&data, (scenedata), sizeof(ParkSceneData));
            NSAssert(data.fourcc == fcc, nil);
            _eventType = data.type;
//            if (data.type >3) {
//                NSLog(@"driving event %d", data.type);
//            } else if (data.type != VIDEO_EVENT_TYPE_NULL && data.type != VIDEO_EVENT_TYPE_Motion){
//                NSLog(@"some event %d", data.type);
//            }
        }
        else if (fcc == MAKE_FOURCC_STR("EVNT")) {
            EventSceneData data;
            memset(&data, 0, sizeof(EventSceneData));
            memcpy(&data, (scenedata), sizeof(EventSceneData));
            NSAssert(data.fourcc == fcc, nil);
            _eventType = data.type;
            switch (data.level) {
                case VIDEO_EVENT_LEVEL_HARSH:
                    if (_eventType == VIDEO_EVENT_TYPE_Hard_Accel) {
                        _eventType = VIDEO_EVENT_TYPE_Harsh_Accel;
                    } else if (_eventType == VIDEO_EVENT_TYPE_Hard_Brake) {
                        _eventType = VIDEO_EVENT_TYPE_Harsh_Brake;
                    } else if (_eventType == VIDEO_EVENT_TYPE_Sharp_Turn) {
                        _eventType = VIDEO_EVENT_TYPE_Harsh_Turn;
                    }
                    break;
                case VIDEO_EVENT_LEVEL_SEVERE:
                    if (_eventType == VIDEO_EVENT_TYPE_Hard_Accel) {
                        _eventType = VIDEO_EVENT_TYPE_Severe_Accel;
                    } else if (_eventType == VIDEO_EVENT_TYPE_Hard_Brake) {
                        _eventType = VIDEO_EVENT_TYPE_Severe_Brake;
                    } else if (_eventType == VIDEO_EVENT_TYPE_Sharp_Turn) {
                        _eventType = VIDEO_EVENT_TYPE_Severe_Turn;
                    }
                    break;

                default:
                    break;
            }
            if (data.date < 5000000000) { // year 2128
                _eventDate = data.date;
            }
            //            if (data.type >3) {
            //                NSLog(@"driving event %d", data.type);
            //            } else if (data.type != VIDEO_EVENT_TYPE_NULL && data.type != VIDEO_EVENT_TYPE_Motion){
            //                NSLog(@"some event %d", data.type);
            //            }
        }
        else if (fcc == MAKE_FOURCC_STR("DMSE")) {
            EventSceneData data;
            memset(&data, 0, sizeof(EventSceneData));
            memcpy(&data, (scenedata), sizeof(EventSceneData));
            NSAssert(data.fourcc == fcc, nil);
            _dmsType = data.dms;
            if (data.date < 5000000000) { // year 2128
                _dmsDate = data.date;
            }
        }
        else if (fcc == MAKE_FOURCC_STR("ADAS")) {
            EventSceneData data;
            memset(&data, 0, sizeof(EventSceneData));
            memcpy(&data, (scenedata), sizeof(EventSceneData));
            NSAssert(data.fourcc == fcc, nil);
            _adasType = data.adas_type;
            if (data.date < 5000000000) { // year 2128
                _adasDate = data.date;
            }
        }
    }

    //    if (inherited.flags & GET_CLIP_RAW_FCC) {
    //        uint32_t num_fcc;
    //        uint32_t fcc[num_fcc];
    //    }
        if (_info.inherited.flags & GET_CLIP_RAW_FCC) {
            uint32_t num_fcc = *((uint32_t*)(pdata + offset));
            uint32_t* fcc = (uint32_t*)(pdata + offset + sizeof(uint32_t));
            for (int i = 0; i < num_fcc; i++) {
                if ((fcc[i] == MAKE_FOURCC_STR("0SMD")) ||
                    (fcc[i] == MAKE_FOURCC_STR("1SMD"))) {
                    _dmsIndex = i;
                }
            }
            offset += (num_fcc + 1) * sizeof(uint32_t);
        }
        if (_info.inherited.flags & GET_CLIP_VIDEO_TYPE) {
            for (int i = 0; i < self.streamNum; i++) {
                uint8_t* type = (uint8_t*)(pdata + offset);
                videoType[i] = *type;
                offset += sizeof(uint32_t);
            }
        }

        if (_info.inherited.flags & GET_CLIP_VIDEO_DESCR) {
            for (int i = 0; i < self.streamNum; i++) {
                uint32_t descr_len = *(uint32_t*)(pdata + offset);
                offset += sizeof(uint32_t);
                if (descr_len != 0) {
                    char descr[descr_len + 1];
                    memset(descr, 0, descr_len + 1);
                    memcpy(descr, (void*)(pdata + offset), descr_len);
                    for (int i = 0; i < descr_len; i++) {
                        if (descr[i] >= '\x7f' || descr[i] <= '\x20') {
                            descr[i] = 0;
                        }
                    }
                    NSString* s = [[NSString alloc] initWithCString:descr encoding:NSUTF8StringEncoding];
                    [streamResolutions addObject:s];
                } else {
                    [streamResolutions addObject:[NSString stringWithFormat:@"stream%d", i]];
                }
                offset += ((descr_len + 3) / 4) * 4;
            }
        } else {
            for (int i = 0; i<self.streamNum; i++) {
                [streamResolutions addObject:[NSString stringWithFormat:@"stream%d", i]];
            }
        }

    //    if (_info.inherited.flags & GET_CLIP_VDB_ID) {
    //        vdb_id_t* vdbid = (vdb_id_t*)(pdata + offset);
    //        if (vdbid->id_size != 0 ) {
    //            int idsize = ((vdbid->id_size + 3)>>2)<<2;
    //            vdbID = [[VDBID alloc]initWithSize:vdbid->id_size Data:[clipdata subdataWithRange:NSMakeRange(offset + sizeof(vdb_id_t), idsize)]];
    //        }
    //    }
}
@end
