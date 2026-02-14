//
//  CameraVBDClientRecv.m
//  Hachi
//
//  Created by gliu on 16/4/18.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import "CameraVDBClient+Recv.h"
#import "WLVDBThumbnailCache.h"
#import "NSData+OBD.h"
#import "WLCameraVDBClient+FrameworkInternal.h"
#import "WLCameraVDBClient+WaylensInternal.h"
#import "WLVDBClip+FrameworkInternal.h"
#import "WLVDBThumbnail+FrameworkInternal.h"
#import "WLDefine.h"
#import "Define+FrameworkInternal.h"
#import "vdb_cmd.h"
#import "vdb_ios_types.h"
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>
#import "WLDmsDataMapperV1.h"
#import "WLDmsDataMapperV3.h"
#import "WLDmsDataMapperV4.h"
#import "WLDmsDataMapperV5.h"
#import "WLDmsDataMapperV6.h"
#import "WLDmsDataMapperV7.h"
#import "WLDmsDataMapperV8.h"
#import "WLDmsDataHeaderMapper.h"

bool read_and_update_pointer(char **bufferPointer, size_t size, void *var, uint32_t *unreadBufferSize) {
    bool success = false;

    if (var == NULL || bufferPointer == NULL) {
        return success;
    }

    if (*unreadBufferSize >= size) {
        memcpy(var, *bufferPointer, size);
        *bufferPointer = *bufferPointer + size;
        *unreadBufferSize = *unreadBufferSize - static_cast<uint32_t>(size);
        success = true;
    }

    return success;
};

@implementation WLCameraVDBClient (Recv)

//////////////
// call onProcessACK in main queue
- (void)onProcessACK:(NSData*)ack {
    vdb_ack_t *pAck = (vdb_ack_t *)[ack bytes];
    // do not call here
    //if(pAck->cmd_code != VDB_MSG_ClipInfo && pAck->cmd_code != VDB_MSG_RawData) NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
    switch (pAck->cmd_code) {
        case VDB_CMD_GetVersionInfo: {
            if(pAck->ret_code == 0) {
                if (self.vdbVersionMajor == 0 && self.vdbVersionMinor == 0) {
                    vdb_ack_GetVersionInfo_t* versionInfor = (vdb_ack_GetVersionInfo_t*)((char*)pAck + sizeof(vdb_ack_t));
                    self.vdbVersionMajor = versionInfor->major;
                    self.vdbVersionMinor = versionInfor->minor;
                    self.osType = versionInfor->os_type;
                    self.hasVDBID = ((versionInfor->flags & VDB_HAS_ID) == VDB_HAS_ID);
                    [self.connectionDelegate socketClientDidConnect:self];
                }
            } else {
                NSLog(@"VDB_CMD_GetVersionInfo return err: %d", pAck->ret_code);
            }
        } break;
        case VDB_CMD_GetClipSetInfo:
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            if(pAck->ret_code == 0) {
                vdb_ack_GetClipSetInfo_t* vdbInfor = (vdb_ack_GetClipSetInfo_t*)((char*)pAck + sizeof(vdb_ack_t));
                //NSLog(@"VDB_CMD_GetClipSetInfo : %d", vdbInfor->total_clips);
                NSMutableArray *clips = [[NSMutableArray alloc] init];
                int i;
                int offset = sizeof(vdb_ack_GetClipSetInfo_t);
                for (i = 0; i < vdbInfor->total_clips; i++) {
                    clipInforEx* _clip = (clipInforEx*)((char*)vdbInfor + offset);
                    int len = sizeof(clipInforEx) + _clip->inherited.num_streams * sizeof(avf_stream_attr_t);
                    uint32_t extrasize = *((int32_t*)((char*)vdbInfor + offset + len - 4));
                    len += extrasize;
                    // TODO: fix parse error
                    if (len > 100000000) {
                        break;
                    }
                    NSData* clipdata = [NSData dataWithBytes:_clip length:len];
                    WLVDBClip *clip = [[WLVDBClip alloc]initWithInforData:clipdata type:vdbInfor->clip_type needDewarp:self.needDewarp];
                    offset += len;
                    [clips addObject:clip];
                }
                if (self.hasVDBID) {
                    for (WLVDBClip* clip in clips) {
                        [clip setVDBID:((char*)vdbInfor + offset)];
                    }
                }
//                NSLog(@"get VBD infor[%u]: %ld", vdbInfor->clip_type, (unsigned long)[clips count]);
                [self.clipsDelegate onGetClips:clips inDomain:(WLVDBDomain)vdbInfor->clip_type];
//                [self.pDelegate OnGetClips:clips inDomain:(WLVDBDomain)vdbInfor->clip_type];
//                [self.pOneTouchUploadDelegate OnGetClips:clips inDomain:(WLVDBDomain)vdbInfor->clip_type];
            }else{
                NSLog(@"VDB_CMD_GetClipSetInfo get error: %d", pAck->ret_code);
            }
            break;
//        case VDB_CMD_GetAllPlaylists: {
//            if(pAck->ret_code == 0) {
//                vdb_ack_GetAllPlaylist_t* plInfor = (vdb_ack_GetAllPlaylist_t*)((char*)pAck + sizeof(vdb_ack_t));
//                NSMutableArray* lists = [[NSMutableArray alloc] init];
//                for(int i = 0; i< plInfor->num_playlists; i++){
//                    playlistInfo* _list = (vdb_playlist_info_t*)((char*)plInfor + sizeof(vdb_ack_GetAllPlaylist_t) + sizeof(vdb_playlist_info_t) * i);
//                    VDBPlayList *list = [[VDBPlayList alloc] initWithInfor:_list];
//                    [lists addObject:list];
//                    //NSLog(@"get playlist[%ld]: %ld", (long)([list getListIndex] - VDBDomain_Playlist1), (long)[list getClipNum]);
//                }
//                [self.playlistDelegate onAllPlaylists:lists];
//            } else {
//                NSLog(@"VDB_CMD_GetAllPlaylists get error: %d", pAck->ret_code);
//            }
//        }
//            break;
        case VDB_CMD_DeleteClip://deprecated
            if(pAck->ret_code == 0) {
            } else {

            }
            break;

        case VDB_CMD_GetIndexPicture: {
            vdb_ack_GetIndexPicture_t* picInfor = (vdb_ack_GetIndexPicture_t*)((char*)pAck + sizeof(vdb_ack_t));
            double startTime = sTimeFloat(picInfor->clip_time_ms_hi, picInfor->clip_time_ms_lo);
            double duration = picInfor->duration * 1.0 / 1000;
//            BOOL canIgnore = (pAck->user2 >> 1);
            BOOL cache = (pAck->user2 & 1);
            if(pAck->ret_code == 0) {
                int rt = sizeof(vdb_ack_t);
                rt += sizeof(vdb_ack_GetIndexPicture_t);
                rt += picInfor->picture_size;
                NSLog(@"+++>get picturen: %d,  %d, %d %d.", picInfor->user_data, pAck->user1, pAck->user2, pAck->cmd_tag);
                if ([ack length] < rt) {
                    NSLog(@"+++>get picturen not eqeue : %d,  %d, %d", (int)[ack length], rt, picInfor->picture_size);
                }
                __block NSData* thumbnail = [NSData dataWithBytes:(char*)picInfor+sizeof(vdb_ack_GetIndexPicture_t) length:picInfor->picture_size];
                __block int clipid = picInfor->clip_id;
                __block int tag = pAck->cmd_tag;
                __block int sessionId = pAck->user1;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.requestDelegate onGetThumbnail:[[WLVDBThumbnail alloc] initWithData:thumbnail
                                                                           startTime:startTime
                                                                            duration:duration
                                                                             forClip:clipid
                                                                             withTag:tag
                                                                           sessionId:sessionId]];
                });
                if (cache) {
                    [[WLVDBThumbnailCache sharedInstance] addThumbnail:thumbnail
                                                      withTimestamp:(long long)picInfor->clip_time_ms_hi << 32 | picInfor->clip_time_ms_lo
                                                        durationInMS:picInfor->duration
                                                             clipID:picInfor->clip_id];
                }
            } else {
                [self.requestDelegate onGetThumbnail:[[WLVDBThumbnail alloc] initWithData:nil
                                                                       startTime:startTime
                                                                        duration:duration
                                                                         forClip:picInfor->clip_id
                                                                         withTag:pAck->cmd_tag]];
            }
            [self onGetThumbnail];
        }
            break;
        case VDB_CMD_GetPlaybackUrl:
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            if (![self.delegate respondsToSelector:@selector(onGetPlayURL:time:tag:)]) {
                break;
            }
            if(pAck->ret_code == 0){
                vdb_ack_GetPlaybackUrl_t* urlInfor = (vdb_ack_GetPlaybackUrl_t*)((char*)pAck + sizeof(vdb_ack_t));
                double startTime = sTimeFloat(urlInfor->real_time_ms_hi, urlInfor->real_time_ms_lo);
                [self.delegate onGetPlayURL:[NSString stringWithUTF8String:(char*)((char*)pAck + sizeof(vdb_ack_t) + sizeof(vdb_ack_GetPlaybackUrl_t))]
                                       time: startTime
                                        tag:pAck->cmd_tag];
            } else {
                [self.delegate onGetPlayURL:nil time:0 tag:pAck->cmd_tag];
            }
            break;
        case VDB_CMD_GetPlaylistPlaybackUrl: {
            if (![self.delegate respondsToSelector:@selector(onGetPlayURL:time:tag:)]) {
                break;
            }
            if(pAck->ret_code == 0){
                vdb_ack_GetPlaylistPlaybackUrl_t *pUrl = (vdb_ack_GetPlaylistPlaybackUrl_t*)((char*)pAck + sizeof(vdb_ack_t));
                [self.delegate onGetPlayURL:[NSString stringWithUTF8String:(char*)((char*)pAck + sizeof(vdb_ack_t) + sizeof(vdb_ack_GetPlaylistPlaybackUrl_t))]
                                       time:pUrl->playlist_start_ms * 0.001
                                        tag:pAck->cmd_tag];
            } else {
                [self.delegate onGetPlayURL:nil time:0 tag:pAck->cmd_tag];
            }
        }
            break;
        case  VDB_CMD_GetUploadUrl: {
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            if (![self.shareDelegate respondsToSelector:@selector(onGetUploadURL:atTime:duration:option:tag:)]) {
                break;
            }
            if (pAck->ret_code == 0) {
                vdb_ack_GetUploadUrl_t *urlInfor = (vdb_ack_GetUploadUrl_t*)((char*)pAck + sizeof(vdb_ack_t));
                double startTime = sTimeFloat(urlInfor->real_time_ms_hi, urlInfor->real_time_ms_lo);
                double duration = urlInfor->length_ms * 1.0 / 1000;
                [self.shareDelegate onGetUploadURL:[NSString stringWithUTF8String:(char*)((char*)pAck + sizeof(vdb_ack_t) + sizeof(vdb_ack_GetUploadUrl_t))]
                                            atTime:startTime
                                          duration:duration
                                            option:urlInfor->upload_opt
                                               tag:pAck->cmd_tag];
            } else {
                [self.shareDelegate onGetUploadURL:nil atTime:0 duration:0 option:0 tag:pAck->cmd_tag];
            }
        }
            break;
        case VDB_CMD_GetRawData:
            if(pAck->ret_code == 0) {
                vdb_ack_GetRawData_t *data = (vdb_ack_GetRawData_t*)((char*)pAck + sizeof(vdb_ack_t));
                char* pointer = (char*)((char*)pAck + sizeof(vdb_ack_t) + sizeof(vdb_ack_GetRawData_t));
                int rt = sizeof(vdb_ack_t);
                rt += sizeof(vdb_ack_GetRawData_t);
                uint32_t createdTime = data->clip_date;
                uint32_t *timeLow, *timeHi;
                while (1) {
                    uint32_t* tmp = (uint32_t*)pointer;
                    if (*tmp == kRawData_GPS) {
                        pointer += sizeof(uint32_t);
                        timeLow = (uint32_t*)pointer;
                        pointer += sizeof(uint32_t);
                        timeHi = (uint32_t*)pointer;
                        double timpoint =  sTimeFloat(*timeHi, *timeLow);
                        pointer += sizeof(uint32_t);
                        tmp = (uint32_t*)pointer;
                        pointer += sizeof(uint32_t);
                        rt += sizeof(uint32_t) * 4;
                        if(*tmp != 0) {
                            gpsInfor_t gps;
                            gps.time = timpoint + createdTime;
                            if ([self parseGPS:&gps size:*tmp at:pointer]) {
                                if ([self.delegate respondsToSelector:@selector(onGpsInforUpdate:inDomain:)]) {
                                    [self.delegate onGpsInforUpdate:&gps inDomain:(WLVDBDomain)data->clip_type];
                                }
                                if ([self.requestDelegate respondsToSelector:@selector(onGetGpsData:inDomain:tag:)] && (pAck->cmd_tag > 0)) {
                                    [self.requestDelegate onGetGpsData:gps inDomain:(WLVDBDomain)data->clip_type tag:pAck->cmd_tag];
                                }
                            }
                        } else {
                            gpsInfor_t gps;
                            gps.hdop = -1;
                            gps.vdop = -1;
                            if ([self.requestDelegate respondsToSelector:@selector(onGetGpsData:inDomain:tag:)] && (pAck->cmd_tag > 0)) {
                                [self.requestDelegate onGetGpsData:gps inDomain:(WLVDBDomain)data->clip_type tag:pAck->cmd_tag];
                            }
                        }
                        pointer += *tmp;
                        rt += *tmp;
                    } else if(*tmp == kRawData_ACC) {
                        pointer += sizeof(uint32_t);
                        timeLow = (uint32_t*)pointer;
                        pointer += sizeof(uint32_t);
                        timeHi = (uint32_t*)pointer;
                        double timpoint = sTimeFloat(*timeHi, *timeLow);
                        pointer += sizeof(uint32_t);
                        tmp = (uint32_t*)pointer;
                        pointer += sizeof(uint32_t);
                        rt += sizeof(uint32_t) * 4;
                        if (*tmp != 0) {
                            if (*tmp == sizeof(acc_raw_data_t)) {
                                acc_raw_data_t *gsensorInfor = (acc_raw_data_t*)pointer;
                                if ([self.delegate respondsToSelector:@selector(onGSensorData:time:clip:inDomain:)]) {
                                    [self.delegate onGSensorData:gsensorInfor time:timpoint clip:data->clip_id inDomain:(WLVDBDomain)data->clip_type];
                                }
                            } else if (*tmp == sizeof(iio_raw_data_t)) {
                                iio_raw_data_t *gsensorInfor = (iio_raw_data_t*)pointer;
                                if (abs(gsensorInfor->euler_roll) > 360000) {
                                    NSLog(@"get wrong roll: %d", gsensorInfor->euler_roll);
                                } else if ([self.delegate respondsToSelector:@selector(onIIOData:time:clip:inDomain:)]){
                                    [self.delegate onIIOData:gsensorInfor time:timpoint+createdTime clip:data->clip_id inDomain:(WLVDBDomain)data->clip_type];
                                }
                            }
                        } else {
                            if (*tmp != 0) {
                                NSLog(@"ACC raw date length error : %d, %d", *tmp, (int)sizeof(acc_raw_data_t));
                            }
                        }
                        pointer += *tmp;
                        rt += *tmp;
                    } else if(*tmp == kRawData_OBD) {
                        pointer += sizeof(uint32_t);
                        timeLow = (uint32_t*)pointer;
                        pointer += sizeof(uint32_t);
                        timeHi = (uint32_t*)pointer;
                        double timpoint = sTimeFloat(*timeHi, *timeLow);
                        pointer += sizeof(uint32_t);
                        tmp = (uint32_t*)pointer;
                        pointer += sizeof(uint32_t);
                        rt += sizeof(uint32_t) * 4;
                        if(*tmp != 0 && [self.delegate respondsToSelector:@selector(onOBDData:time:clip:inDomain:)]) {
                            [self.delegate onOBDData:[NSData dataWithBytes:(char*)pointer length:(int)*tmp] time:timpoint clip:data->clip_id inDomain:(WLVDBDomain)data->clip_type];
                        }
                        pointer += *tmp;
                        rt += *tmp;
                    }else if(*tmp == kRawData_NULL)  {
                        rt += sizeof(uint32_t);
                        break;
                    }
                }
                if ((rt >  [ack length])&&([ack length] > VDB_ACK_SIZE)) {
                    NSLog(@"+++>get RAW DATA not eqeue : %d,  %d", (int)[ack length], rt);
                }
            } else {

            }
            break;
        case VDB_CMD_SetRawDataOption: {
        }
            break;
        case VDB_CMD_GetRawDataBlock:
            if(pAck->ret_code == 0) {
                NSLog(@"VDB_CMD_GetRawDataBlock (tag:%x) return 0", pAck->cmd_tag);
                vdb_ack_GetRawDataBlock_t *data = (vdb_ack_GetRawDataBlock_t*)((char*)pAck + sizeof(vdb_ack_t));
                int rt = sizeof(vdb_ack_t);
                rt += sizeof(vdb_ack_GetRawDataBlock_t);
                rt += data->num_items * sizeof(vdb_raw_data_index_t);
                vdb_raw_data_index_t *indexs = (vdb_raw_data_index_t*)((char*)data + sizeof(vdb_ack_GetRawDataBlock_t));
                if (rt > [ack length] && ([ack length] > VDB_ACK_SIZE)) {
                    NSLog(@"+++>get RAW DATA(%d) Err 0: %d,  %d", data->data_type, (int)[ack length], rt);
                    break;
                }
                int datalength = 0;
                for (int i = 0; i<data->num_items; i++) {
                    datalength+= indexs[i].data_size;
                }
                rt += datalength;
                if (rt > [ack length] && ([ack length] > VDB_ACK_SIZE)) {
                    NSLog(@"+++>get RAW DATA(%d) Err 1: %d,  %d", data->data_type, (int)[ack length], rt);
                    break;
                }
                NSMutableData *getData = [[NSMutableData alloc] initWithBytes:((char*)indexs + data->num_items * sizeof(vdb_raw_data_index_t)) length:datalength];
                double timpoint = sTimeFloat(data->requested_time_ms_hi, data->requested_time_ms_lo) + data->clip_date;
                static iioInfor_t lastiio;
                NSLog(@"VDB_CMD_GetRawDataBlock return %d items [len: %d]", (int)data->num_items, datalength);
                switch (data->data_type) {
                    case kRawData_ACC: {
                        NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:data->num_items];
                        int offset = 0;
                        BOOL bACCorIIO = YES;
                        if ((data->num_items > 0) &&
                            ([getData length] / data->num_items > sizeof(acc_raw_data_t))) {
                            bACCorIIO = NO;
                        }
                        for (int i = 0; i<data->num_items; i++) {
                            iioInfor_t iio;
                            if (bACCorIIO) {
                                char* bytes = ((char*)indexs + data->num_items * sizeof(vdb_raw_data_index_t)) + offset;
                                if ((i + 1) * sizeof(acc_raw_data_t) > [getData length]) {
                                    break;
                                }
                                acc_raw_data_t *pdata = (acc_raw_data_t*)bytes;
                                memcpy(&(iio.iio), pdata, sizeof(acc_raw_data_t));
                                iio.time = timpoint + indexs[i].time_offset_ms/1000.0;
                                offset+= indexs[i].data_size;
                            } else {
                                if ((i + 1) * sizeof(iio_raw_data_t) > [getData length]) {
                                    break;
                                }
                                char* pointer = (char*)[getData bytes] + i * sizeof(iio_raw_data_t);
                                iio_raw_data_t *pdata = (iio_raw_data_t*)pointer;
                                memcpy(&(iio.iio), pdata, sizeof(iio_raw_data_t));
                                iio.time = timpoint + indexs[i].time_offset_ms/1000.0;
                            }
                            memcpy(&lastiio, &iio, sizeof(iio));
                            [arr addObject:[NSData dataWithBytes:&iio length:sizeof(iioInfor_t)]];
                        }
                        [self.cacheDelegate onACCPathUpdateclip:data->clip_id array:arr inDomain:(WLVDBDomain)data->clip_type];
                    }
                        break;
                    case kRawData_GPS: {
                        NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:data->num_items];
                        int offset = 0;
                        for (int i = 0; i<data->num_items; i++) {
                            char* bytes = ((char*)indexs + data->num_items * sizeof(vdb_raw_data_index_t)) + offset;
                            gpsInfor_t gps;
                            gps.orientation = 0;
                            gps.time = timpoint + indexs[i].time_offset_ms/1000.0;
                            //                            gps.clipid = data->clip_id;
                            if ([self parseGPS:&gps size:indexs[i].data_size at:bytes]) {
                                [arr addObject:[NSData dataWithBytes:&gps length:sizeof(gpsInfor_t)]];
                            }
                            offset+= indexs[i].data_size;
                        }
                        [self.cacheDelegate onGPSPathUpdateclip:data->clip_id path:arr inDomain:(WLVDBDomain)data->clip_type];
                    }
                        break;
                    case kRawData_OBD: {
                        NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:data->num_items];
                        int offset = 0;
                        for (int i = 0; i<data->num_items; i++) {
                            char* bytes = ((char*)indexs + data->num_items * sizeof(vdb_raw_data_index_t)) + offset;
                            obdInfor_t obd;
                            NSData *pdata = [NSData dataWithBytes:bytes length:indexs[i].data_size];
                            if (pdata.length == 0) {
                                continue;
                            }
                            obd.time = timpoint + indexs[i].time_offset_ms/1000.0;
                            obd.speed = [pdata getOBDSpeed];
                            obd.rpm = [pdata getOBDRPM];
                            obd.throttle = [pdata getOBDThrottle];
                            obd.psi = [pdata getOBDPsiWithPressure:lastiio.iio.pressure/1000000];
                            obd.barometricPressure = [pdata getOBDBarometricPressureWithPressure:lastiio.iio.pressure/1000000];
                            [arr addObject:[NSData dataWithBytes:&obd length:sizeof(obdInfor_t)]];
                            offset+= indexs[i].data_size;
                        }
                        [self.cacheDelegate onOBDPathUpdateclip:data->clip_id array:arr inDomain:(WLVDBDomain)data->clip_type];
                    }
                        break;
                    default:
                        break;
                }
            } else {
                uint32_t tag = pAck->cmd_tag;
                int type = (tag >> 28);
                WLVDBDomain domain = (WLVDBDomain)((tag >> 16) & 0xff);
                BOOL bCache = ((tag >> 27) & 0x01) != 0;
                if (bCache) {
                    switch (type) {
                        case kRawData_GPS:
                            [self.cacheDelegate onGPSPathUpdateclip:pAck->user1 path:[NSMutableArray new] inDomain:domain];
                            break;
                        case kRawData_ACC:
                            [self.cacheDelegate onACCPathUpdateclip:pAck->user1 array:[NSMutableArray new] inDomain:domain];
                            break;
                        case kRawData_OBD:
                            [self.cacheDelegate onOBDPathUpdateclip:pAck->user1 array:[NSMutableArray new] inDomain:domain];
                            break;
                        default:
                            break;
                    }
                } else {
                }
                NSLog(@"get %d datablock (domain:%d) return failed : %x", type, domain, pAck->ret_code);
            }
            break;
        case VDB_CMD_GetExtraRawData:
            if(pAck->ret_code == 0) {
                vdb_ack_GetExtraRawData_t *data = (vdb_ack_GetExtraRawData_t*)((char*)pAck + sizeof(vdb_ack_t));
                char* pointer = (char*)((char*)pAck + sizeof(vdb_ack_t) + sizeof(vdb_ack_GetExtraRawData_t));
                int rt = sizeof(vdb_ack_t);
                rt += sizeof(vdb_ack_GetExtraRawData_t);
                //uint32_t createdTime = data->clip_date;
                uint32_t *timeLow, *timeHi;
                NSString* recordConfig = @"";
                if(self.clipsDelegate) {
                    recordConfig = [self.clipsDelegate getRecordConfigFromClip:data->clip_id inDomain:(WLVDBDomain)data->clip_type];
                }
                if (*(uint32_t*)pointer == 0) {
                    if ([self.delegate respondsToSelector:@selector(onDMSESData:time:clip:inDomain:withRecordConfig:)]) {
                        [self.delegate onDMSESData:nil
                                              time:0
                                              clip:data->clip_id
                                          inDomain:(WLVDBDomain)data->clip_type
                                  withRecordConfig:recordConfig];
                    }
                }
                while (1) {
                    uint32_t* raw_fcc = (uint32_t*)pointer;
                    if (*raw_fcc == 0) {
                        break;
                    }
                    pointer += sizeof(uint32_t);
                    timeLow = (uint32_t*)pointer;
                    pointer += sizeof(uint32_t);
                    timeHi = (uint32_t*)pointer;
                    double timpoint =  sTimeFloat(*timeHi, *timeLow);
//                    NSLog(@"VDB_CMD_GetExtraRawData (tag:%x) time: %0.3f", pAck->cmd_tag, timpoint);
                    pointer += sizeof(uint32_t);
                    uint32_t data_size = *((uint32_t*)pointer);
                    pointer += sizeof(uint32_t);
                    rt += sizeof(uint32_t) * 4;
                    if (data->data_types == 0) {
                        if ([self.delegate respondsToSelector:@selector(onDMSData:time:clip:inDomain:withRecordConfig:)]) {
                            [self.delegate onDMSData:nil time:timpoint clip:data->clip_id inDomain:(WLVDBDomain)data->clip_type withRecordConfig:recordConfig];
                        }
                        return;
                    }
                    if (*raw_fcc == MAKE_FOURCC_STR("0SMD")) {
                        if(data_size == sizeof(readsense_dms_data_t) ||
                           data_size == sizeof(readsense_dms_data_v2_t)) {
                            readsense_dms_data_faceid_t* faceid = NULL;
                            if (data_size == sizeof(readsense_dms_data_v2_t)) {
                                faceid = (readsense_dms_data_faceid_t*)(pointer + sizeof(readsense_dms_data_v2_t) - sizeof(readsense_dms_data_faceid_t));
                                if ([self.delegate respondsToSelector:@selector(onDMSData:time:clip:inDomain:withRecordConfig:)]) {
                                    [self.delegate onDMSData:(readsense_dms_data_v2_t*)pointer time:timpoint clip:data->clip_id inDomain:(WLVDBDomain)data->clip_type withRecordConfig:recordConfig];
                                }
                            } else {
                                if ([self.delegate respondsToSelector:@selector(onDMSData:time:clip:inDomain:withRecordConfig:)]) {
                                    readsense_dms_data_v2_t dms;
                                    dms.v1 = *((readsense_dms_data_t*)pointer);
                                    dms.face.faceid = 0;
                                    dms.face.faceid_valid = 0;
                                    [self.delegate onDMSData:&dms time:timpoint clip:data->clip_id inDomain:(WLVDBDomain)data->clip_type withRecordConfig:recordConfig];
                                }
                            }
                        } else if(data_size == sizeof(readsense_dms_data_header_t)) {
                            if ([self.delegate respondsToSelector:@selector(onDMSData:time:clip:inDomain:withRecordConfig:)]) {
                                [self.delegate onDMSData:nil time:timpoint clip:data->clip_id inDomain:(WLVDBDomain)data->clip_type withRecordConfig:recordConfig];
                            }
                        } else {
                            NSLog(@"-- get wrong DMS size %d(%lu/%lu)", data_size,
                                  sizeof(readsense_dms_data_t), sizeof(readsense_dms_data_v2_t));
                            if ([self.delegate respondsToSelector:@selector(onDMSData:time:clip:inDomain:withRecordConfig:)]) {
                                [self.delegate onDMSData:nil time:timpoint clip:data->clip_id inDomain:(WLVDBDomain)data->clip_type withRecordConfig:recordConfig];
                            }
                        }
                    } else if (*raw_fcc == MAKE_FOURCC_STR("1SMD")) {
                        uint32_t leftsize = data_size;
                        WLDmsData *dmsData = [self parseDMSDataInBuffer:pointer bufferSize:leftsize];

                        if ([self.delegate respondsToSelector:@selector(onDMSESData:time:clip:inDomain:withRecordConfig:)]) {
                            [self.delegate onDMSESData:dmsData
                                                  time:timpoint
                                                  clip:data->clip_id
                                              inDomain:(WLVDBDomain)data->clip_type
                                      withRecordConfig:recordConfig];
                        }
                    } else {
                        NSLog(@"-- get fcc: 0x%x, dms0: 0x%x", *raw_fcc, MAKE_FOURCC_STR("DMS0"));
                    }
                    pointer += data_size;
                    rt += data_size;
                }
                if ((rt >  [ack length])&&([ack length] > VDB_ACK_SIZE)) {
                    NSLog(@"+++>get EXRAW DATA not eqeue : %d,  %d", (int)[ack length], rt);
                }
            } else {
                NSLog(@"-- get ExtraRawData error");
            }
            //_pCmdSync->Give();
            break;
        case VDB_CMD_GetDownloadUrl:
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            if(pAck->ret_code == 0) {
            } else {
                NSLog(@"-- get download Url error");
            }
            //_pCmdSync->Give();
            break;
        case VDB_CMD_GetDownloadUrlEx:
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            if(pAck->ret_code == 0) {
                vdb_ack_GetDownloadUrlEx_t *durlInfor = (vdb_ack_GetDownloadUrlEx_t*)((char*)pAck + sizeof(vdb_ack_t));
                vdb_stream_url_t mainStream;
                vdb_stream_url_t subStream;
                vdb_stream_url_t subNStream;
                NSString* urlMain = Nil;
                NSString* urlSub = Nil;
                NSString* urlSubN = Nil;
                double mainsizek = 0;
                double subsizek = 0;
                double subNsizek = 0;
                int len = 0;
                unsigned int length = 0;
                double dd = 0;
                NSDate *mainDate = Nil;
                NSLog(@"-- get download:%d", durlInfor->download_opt);
                if (durlInfor->download_opt & DOWNLOAD_OPT_MAIN_STREAM) {
                    memcpy(&mainStream, ((char*)durlInfor + sizeof(vdb_ack_GetDownloadUrlEx_t)), sizeof(vdb_stream_url_t));
                    len += sizeof(vdb_stream_url_t) + mainStream.url_size;
                    urlMain =
                    [NSString stringWithFormat:@"%s%@", ((char*)durlInfor + sizeof(vdb_ack_GetDownloadUrlEx_t)) + sizeof(vdb_stream_url_t), @",0,-1;"];
                    mainsizek = sTimeFloat(mainStream.size_hi, mainStream.size_lo);
                    length = mainStream.length_ms;
                    //Time64()
                    dd = sTimeFloat(mainStream.clip_time_ms_hi, mainStream.clip_time_ms_lo) + mainStream.clip_date;
                    //NSLog(@"main stream time : %f", dd);
                    NSDate *now = [NSDate date];
                    NSTimeZone *zone = [NSTimeZone systemTimeZone];
                    NSInteger interval = [zone secondsFromGMTForDate: now];
                    mainDate = [NSDate dateWithTimeIntervalSince1970:dd-interval];
                }
                if (durlInfor->download_opt & DOWNLOAD_OPT_SUB_STREAM_1) {
                    memcpy(&subStream, ((char*)durlInfor + sizeof(vdb_ack_GetDownloadUrlEx_t) + len), sizeof(vdb_stream_url_t));
                    len += sizeof(vdb_stream_url_t);
                    urlSub = [NSString stringWithFormat:@"%s%@", ((char*)durlInfor + sizeof(vdb_ack_GetDownloadUrlEx_t) + len), @",0,-1;"];
                    len += subStream.url_size;
                    subsizek = sTimeFloat(subStream.size_hi, subStream.size_lo);
                    length = subStream.length_ms;
                    dd = sTimeFloat(subStream.clip_time_ms_hi, subStream.clip_time_ms_lo) + subStream.clip_date;;
                    NSDate *now = [NSDate date];
                    NSTimeZone *zone = [NSTimeZone systemTimeZone];
                    NSInteger interval = [zone secondsFromGMTForDate: now];
                    mainDate = [NSDate dateWithTimeIntervalSince1970:dd-interval];
                }
                if (durlInfor->download_opt & DOWNLOAD_OPT_SUB_STREAM_N) {
                    memcpy(&subNStream, ((char*)durlInfor + sizeof(vdb_ack_GetDownloadUrlEx_t) + len), sizeof(vdb_stream_url_t));
                    len += sizeof(vdb_stream_url_t);
                    urlSubN = [NSString stringWithFormat:@"%s%@", ((char*)durlInfor + sizeof(vdb_ack_GetDownloadUrlEx_t) + len), @",0,-1;"];
                    len += subNStream.url_size;
                    subNsizek = sTimeFloat(subNStream.size_hi, subNStream.size_lo);
                    length = subNStream.length_ms;
                    dd = sTimeFloat(subNStream.clip_time_ms_hi, subNStream.clip_time_ms_lo) + subNStream.clip_date;;
                    NSDate *now = [NSDate date];
                    NSTimeZone *zone = [NSTimeZone systemTimeZone];
                    NSInteger interval = [zone secondsFromGMTForDate: now];
                    mainDate = [NSDate dateWithTimeIntervalSince1970:dd-interval];
                }
                if (self.shareDelegate) {
                    [self.shareDelegate onGetDownloadURL:urlMain
                                                mainsize:mainsizek
                                                     sub:urlSub
                                                 subsize:subsizek
                                                    subn:urlSubN
                                                subnsize:subNsizek
                                                    Date:mainDate
                                                  length:length
                                              forCapture:pAck->user2];
                }
                if (self.requestDelegate) {
                    [self.requestDelegate onGetDownloadURL:urlMain
                                                  mainsize:mainsizek
                                                       sub:urlSub
                                                   subsize:subsizek
                                                      subn:urlSubN
                                                  subnsize:subNsizek
                                                      date:mainDate
                                                    length:length
                                                       tag:pAck->cmd_tag];
                }
            }
            break;
        case VDB_CMD_MarkClip: {
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            BOOL result = NO;
            if(pAck->ret_code == 0) {
                vdb_ack_MarkClip_t *pResult = (vdb_ack_MarkClip_t*)((char*)pAck + sizeof(vdb_ack_t));
                if (pResult->status == 0) {
                    result = YES;
                }
            }
            if([self.delegate respondsToSelector:@selector(onClipMark:)])
                [self.delegate onClipMark:result];
        }
            break;
        case VDB_CMD_SetClipData: {
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            BOOL result = (pAck->ret_code == 0);
            NSDictionary *userinfo = @{@"result":@(result)};
            NSNotification *note = [[NSNotification alloc] initWithName:@"VDB_CMD_SetClipData" object:nil userInfo:userinfo];
            [[NSNotificationCenter defaultCenter] postNotification:note];
        }
            break;
        case VDB_CMD_GetSpaceInfo: {
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            long long total = 0;
            long long used = 0;
            long long marked = 0;
            long long clip = 0;
            if(pAck->ret_code == 0) {
                vdb_space_info_t *info = (vdb_space_info_t*)((char*)pAck + sizeof(vdb_ack_t));
                total = (long long)info->total_space_hi << 32 | info->total_space_lo;
                used = (long long)info->used_space_hi << 32 | info->used_space_lo;
                marked = (long long)info->protected_space_hi << 32 | info->protected_space_lo;
                clip = (long long)info->clip_space_hi << 32 | info->clip_space_lo;
            }
            if(self.spaceDelegate) [self.spaceDelegate onGetCameraSpaceTotal:total free:total-used clip:clip marked:marked];
        }
            break;
        case VDB_MSG_RawData:
            //NSLog(@"get VDB_MSG_RawData");
            if(pAck->ret_code == 0) {
                vdb_msg_RawData_t *data = (vdb_msg_RawData_t*)((char*)pAck);
                char* praw = (char*)((char*)pAck + sizeof(vdb_msg_RawData_t));
                int rt = sizeof(vdb_msg_RawData_t);
                switch (data->data_type) {
                    case kRawData_GPS:
                        if ([self.liveDelegate respondsToSelector:@selector(onLiveGPS:)]) {
                            [self.liveDelegate onLiveGPS:[NSData dataWithBytes:praw length:data->data_size]];
                        }
                        break;
                    case kRawData_ACC:
                        if ([self.liveDelegate respondsToSelector:@selector(onLiveACC:)]) {
                            [self.liveDelegate onLiveACC:[NSData dataWithBytes:praw length:data->data_size]];
                        }
                        break;
                    case kRawData_OBD:
                        if ([self.liveDelegate respondsToSelector:@selector(onLiveOBD:)]) {
                            [self.liveDelegate onLiveOBD:[NSData dataWithBytes:praw length:data->data_size]];
                        }
                        break;
                    case MAKE_FOURCC_STR("DMS0"):
                        [self.dmsLiveDelegate onLiveRSDMS:[NSData dataWithBytes:praw length:data->data_size]];
                        break;
                    case MAKE_FOURCC_STR("DMS1"): {
                        uint32_t leftsize = data->data_size;
                        WLDmsData *dmsData = [self parseDMSDataInBuffer:praw bufferSize:leftsize];

                        [self.dmsLiveDelegate onLiveESDMS:dmsData];

                        if ([self.liveDelegate respondsToSelector:@selector(onLiveDMS:)]) {
                            [self.liveDelegate onLiveDMS:dmsData];
                        }
                    }
                        break;
                    default:
                        break;
                }
                rt += data->data_size;
                if ((rt !=  [ack length])&&([ack length] > VDB_ACK_SIZE)) {
                    NSLog(@"+++>get RAW DATA %d not eqeue : %d,  %d", data->data_type, (int)[ack length], rt);
                }
            }
            break;
        case VDB_MSG_RawDataEx: {
            vdb_msg_RawDataEx_t *data = (vdb_msg_RawDataEx_t*)((char*)pAck);
            if (data->data_type == MAKE_FOURCC_STR("DMS0") &&
                (data->data_size == sizeof(readsense_dms_data_t) ||
                 data->data_size == sizeof(readsense_dms_data_v2_t))) {
                uint8_t *pdata = (uint8_t*)(data + 1);
                pdata += data->extra_size;
                [self.dmsLiveDelegate onLiveRSDMS:[NSData dataWithBytes:pdata length:data->data_size]];
            } else
            if (data->data_type == MAKE_FOURCC_STR("DMS1")) {
                // in fact, dms data is poped in msg VDB_MSG_RawData, not here
            }
        }
            break;
        case VDB_MSG_ClipInfo:
            if(pAck->ret_code == 0) {
                vdb_msg_ClipInfo_t* clipInfor = (vdb_msg_ClipInfo_t*)((char*)pAck);
                [self onClipUpdate:clipInfor];
            } else {
            }
            break;
        case VDB_MSG_CLIP_ATTR:
            if(pAck->ret_code == 0) {
                //vdb_msg_ClipAttr_t* clipInfor = (vdb_msg_ClipAttr_t*)((char*)pAck);
            } else {
            }
            break;
        case VDB_MSG_BufferSpaceLow:
            NSLog(@"--!!!!---MSG SPACE LOW");

            break;
        case VDB_MSG_BufferFull:
            //NSLog(@"--!!!!---MSG SPACE FULL");
            break;
        case VDB_MSG_ClipRemoved: {
            NSLog(@"--!!!!---MSG CLIP REMOVED");
            vdb_msg_ClipRemoved_t* delInfor = (vdb_msg_ClipRemoved_t*)((char*)pAck);
            if(pAck->ret_code == 0) {
                if(self.clipsDelegate) {
                    __block int clipid = delInfor->clip_id;
                    __block WLVDBDomain domain = (WLVDBDomain)delInfor->clip_type;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.clipsDelegate onClipRemove:clipid inDomain:domain];
                    });
                }
            }
        }
            break;
        case VDB_CMD_GetPlaylistIndexPicture: {
            vdb_ack_GetPlaylistIndexPicture_t* picInfor = (vdb_ack_GetPlaylistIndexPicture_t*)((char*)pAck + sizeof(vdb_ack_t));
            if(pAck->ret_code == 0) {
                int rt = sizeof(vdb_ack_t);
                rt += sizeof(vdb_ack_GetPlaylistIndexPicture_t);
                rt += picInfor->picture_size;
                if ([ack length] != rt) {
                    NSLog(@"+++>get picturen not eqeue : %d,  %d, %d", (int)[ack length], rt, picInfor->picture_size);
                }
                if ([self.requestDelegate respondsToSelector:@selector(onGetThumbnail:)]) {
                    [self.requestDelegate onGetThumbnail:[[WLVDBThumbnail alloc] initWithData:[NSData dataWithBytes:(char*)picInfor+sizeof(vdb_ack_GetPlaylistIndexPicture_t) length:picInfor->picture_size]
                                                                           startTime:0
                                                                            duration:0
                                                                             forClip:picInfor->list_type
                                                                             withTag:pAck->cmd_tag]];
                }
            } else if ([self.requestDelegate respondsToSelector:@selector(onGetThumbnail:)]) {
                [self.requestDelegate onGetThumbnail:[[WLVDBThumbnail alloc] initWithData:nil
                                                                       startTime:0
                                                                        duration:0
                                                                         forClip:picInfor->list_type
                                                                         withTag:pAck->cmd_tag]];
            }
        }
            break;
        /*
        case VDB_CMD_ClearPlaylist: {
            if(pAck->ret_code == 0){
                vdb_ack_ClearPlaylist_t* ret = (vdb_ack_ClearPlaylist_t*)((char*)pAck + sizeof(vdb_ack_t));
                [self.playlistDelegate onPlaylistClear:ret->status];
            } else {
                [self.playlistDelegate onPlaylistClear:pAck->ret_code];
            }
        }
            break;
        case VDB_CMD_InsertClipEx:
        case VDB_CMD_InsertClip: {
            if(pAck->ret_code == 0){
                vdb_ack_InsertClip_t* ret = (vdb_ack_InsertClip_t*)((char*)pAck + sizeof(vdb_ack_t));
                [self.playlistDelegate onClipInsert:ret->status];
            }
        }
            break;
        case VDB_CMD_MoveClip: {
            if(pAck->ret_code == 0){
                vdb_ack_MoveClip_t* ret = (vdb_ack_MoveClip_t*)((char*)pAck + sizeof(vdb_ack_t));
                [self.playlistDelegate onClipMove:(ret->status == e_MoveClip_OK)];
            }
        }
            break;
        case VDB_MSG_PlaylistCleared:
            NSLog(@"--!!!!---MSG PlaylistCleared");
            if(pAck->ret_code == 0){
            }
            break;
         */
            
            //1.2
        case VDB_CMD_GetClipExtent: {
            if(pAck->ret_code == 0){
                vdb_ack_GetClipExtent_t* clipInfor = (vdb_ack_GetClipExtent_t*)((char*)pAck + sizeof(vdb_ack_t));
                if ([self.delegate respondsToSelector:@selector(onGetClipExtent:)]) {
                    [self.delegate onGetClipExtent:clipInfor];
                }
            } else{
                NSLog(@"VDB_CMD_GetClipExtent get error: %d", pAck->ret_code);
            }
        } break;
        case VDB_CMD_SetClipExtent: {
            if(pAck->ret_code == 0){
                vdb_ack_SetClipExtent_t* clipInfor = (vdb_ack_SetClipExtent_t*)((char*)pAck + sizeof(vdb_ack_t));
                if ([self.delegate respondsToSelector:@selector(onSetClipExtentResult:)]) {
                    [self.delegate onSetClipExtentResult:clipInfor->status];
                }
            } else{
                NSLog(@"VDB_CMD_SetClipExtent get error: %d", pAck->ret_code);
                if ([self.delegate respondsToSelector:@selector(onSetClipExtentResult:)]) {
                    [self.delegate onSetClipExtentResult:pAck->ret_code];
                }
            }
        } break;
        case VDB_CMD_GetClipSetInfoEx: {
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            if(pAck->ret_code == 0) {
                vdb_ack_GetClipSetInfoEx_t* vdbInfor = (vdb_ack_GetClipSetInfoEx_t*)((char*)pAck + sizeof(vdb_ack_t));
                //NSLog(@"vdb_ack_GetClipSetInfoEx_t : %d", vdbInfor->total_clips);
                NSMutableArray *clips = [[NSMutableArray alloc] init];
                int i;
                int offset = sizeof(vdb_ack_GetClipSetInfoEx_t);
                for (i = 0; i < vdbInfor->total_clips; i++) {
                    clipInforEx* _clip = (clipInforEx*)((char*)vdbInfor + offset);
                    int len = sizeof(clipInforEx) + _clip->inherited.num_streams * sizeof(avf_stream_attr_t);
                    uint32_t extrasize = *((int32_t*)((char*)vdbInfor + offset + len - 4));
                    bool getWrongSize = false;
                    if (offset + len + extrasize > ack.length) {
                        NSLog(@"wrong extrasize:%d", extrasize);
                        _clip->extra_size = 0;
                        extrasize = 0;
                        getWrongSize = true;
                        if (_clip->inherited.clip_duration_ms == 0) {
                            break;
                        }
                    }
                    len += extrasize;
                    NSData* clipdata = [NSData dataWithBytes:(char*)_clip length:len];
                    WLVDBClip *clip = [[WLVDBClip alloc] initWithInforExData:clipdata needDewarp:self.needDewarp];
                    offset += len;
                    [clips addObject:clip];
                    if (getWrongSize) {
                        break;
                    }
                }
                if (self.hasVDBID) {
                    for (WLVDBClip* clip in clips) {
                        [clip setVDBID:((char*)vdbInfor + offset)];
                    }
                }
//                NSLog(@"get VBD Exinfor[%u]: %ld", vdbInfor->clip_type, (unsigned long)[clips count]);
//                if (pAck->cmd_tag == 1) {
//                    [self.pCacheDelegate OnGetClips:clips inDomain:(WLVDBDomain)vdbInfor->clip_type];
//                } else {
//                    [self.pDelegate OnGetClips:clips inDomain:(WLVDBDomain)vdbInfor->clip_type];
//                    [self.pOneTouchUploadDelegate OnGetClips:clips inDomain:(WLVDBDomain)vdbInfor->clip_type];
//                }
                if (vdbInfor->clip_type == CLIP_TYPE_BUFFER || vdbInfor->clip_type == CLIP_TYPE_MARKED) {
                    [self.clipsDelegate onGetClips:clips inDomain:(WLVDBDomain)vdbInfor->clip_type];
                } else {
//                    [self.playlistDelegate onGetClips:clips forPlayList:vdbInfor->clip_type];
                }
            } else{
                //                NSLog(@"VDB_CMD_GetClipSetInfoEx get error: %d", pAck->ret_code);
            }
        } break;
        case VDB_CMD_GetClipInfo: {
            if(pAck->ret_code == 0){
                vdb_ack_GetClipInfo_t* vdbInfor = (vdb_ack_GetClipInfo_t*)((char*)pAck + sizeof(vdb_ack_t));
                int len = sizeof(clipInforEx) + vdbInfor->info.inherited.num_streams * sizeof(avf_stream_attr_t);
                uint32_t extrasize = *((int32_t*)((char*)vdbInfor + len - 4));
                len += extrasize;
                NSData* clipdata = [ack subdataWithRange:NSMakeRange(sizeof(vdb_ack_t), [ack length] - sizeof(vdb_ack_GetClipInfo_t))];
                WLVDBClip *clip = [[WLVDBClip alloc] initWithInforExData:clipdata needDewarp:self.needDewarp];
//                [clip setVDBID:((char*)vdbInfor + len)];
//                if (clip.clipType == CLIP_TYPE_MARKED) {
                    [self.clipsDelegate onGetClipInfo:clip for:clip.clipID];
//                } else {
//                    [self.delegate onGetClipInfo:clip];
//                }
            } else{
                NSLog(@"VDB_CMD_GetClipInfo get error: %d", pAck->ret_code);
            }
        } break;
        case VDB_CMD_GetAllClipSetInfo: {
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            if(pAck->ret_code == 0) {
                vdb_ack_GetAllClipSetInfo_t* vdbInfor = (vdb_ack_GetAllClipSetInfo_t*)((char*)pAck + sizeof(vdb_ack_t));
                NSLog(@"total_clips: %u", vdbInfor->total_clips);
                int i;
                int offset = sizeof(vdb_ack_GetAllClipSetInfo_t);
                NSMutableArray *clips = [[NSMutableArray alloc] init];
                for (i = 0; i < vdbInfor->total_clips; i++) {
                    clipInforEx* _clip = (clipInforEx*)((char*)vdbInfor + offset);
                    int len = sizeof(clipInforEx) + _clip->inherited.num_streams * sizeof(avf_stream_attr_t);
                    uint32_t extrasize = *((int32_t*)((char*)vdbInfor + offset + len - 4));
                    len += extrasize;
                    NSData* clipdata = [NSData dataWithBytes:(char*)_clip length:len];
                    WLVDBClip *clip = [[WLVDBClip alloc] initWithInforExData:clipdata needDewarp:self.needDewarp];
                    offset += len;
                    [clips addObject:clip];
                }
                [self.clipsDelegate onGetClips:clips inDomain:VDBDomain_Album];
            } else{
                NSLog(@"VDB_CMD_GetAllClipSetInfo get error: %d", pAck->ret_code);
            }
        } break;
        case VDB_CMD_GetPlaybackUrlEx:
            NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
            if(pAck->ret_code == 0){
                vdb_ack_GetPlaybackUrlEx_t *pUrl = (vdb_ack_GetPlaybackUrlEx_t*)((char*)pAck + sizeof(vdb_ack_t));
                double startTime = sTimeFloat(pUrl->real_time_ms_hi, pUrl->real_time_ms_lo);
                if (pUrl->url_type == URL_TYPE_TS && [self.delegate respondsToSelector:@selector(onGetTSUrl:tag:)]) {
//                    [self.delegate onGetTSUrl:[NSString stringWithUTF8String:(char*)((char*)pAck + sizeof(vdb_ack_t) + sizeof(vdb_ack_GetPlaybackUrlEx_t))] tag:pAck->cmd_tag];
                }
                if ((pUrl->url_type == URL_TYPE_HLS ||
                     pUrl->url_type == URL_TYPE_MP4)
                    && [self.delegate respondsToSelector:@selector(onGetPlayURL:time:tag:)]) {
                    [self.delegate onGetPlayURL:[NSString stringWithUTF8String:(char*)((char*)pAck + sizeof(vdb_ack_t) + sizeof(vdb_ack_GetPlaybackUrlEx_t))]
                                           time: startTime
                                            tag:pAck->cmd_tag];
                }
            } else {
                if (pAck->user1 == URL_TYPE_TS && [self.delegate respondsToSelector:@selector(onGetTSUrl:tag:)]) {
                    [self.delegate onGetTSUrl:nil tag:pAck->cmd_tag];
                }
                if ((pAck->user1 == URL_TYPE_HLS ||
                     pAck->user1 == URL_TYPE_MP4)
                    && [self.delegate respondsToSelector:@selector(onGetPlayURL:time:tag:)]) {
                    [self.delegate onGetPlayURL:nil time:0 tag:pAck->cmd_tag];
                }
            }
            break;
            
//#pragma MSGs
        case VDB_MSG_VdbReady: {
            self.isReady = YES;
            [self updateSpaceInfo];
        }
            break;
        case VDB_MSG_VdbUnmounted: {
            self.isReady = NO;
            if(self.spaceDelegate) [self.spaceDelegate onGetCameraSpaceTotal:0 free:0 clip:0 marked:0];
        }
            break;
        case VDB_MSG_MarkLiveClipInfo: {
            if(pAck->ret_code == 0) {
                vdb_msg_MarkLiveClipInfo_t* vdbInfor = (vdb_msg_MarkLiveClipInfo_t*)((char*)pAck);
                [self.clipsDelegate onClipUpdate:&vdbInfor->super];
            } else{
                NSLog(@"VDB_CMD_GetClipInfo get error: %d", pAck->ret_code);
            }
        }
            break;
        case VDB_MSG_SpaceInfo: {
            if(pAck->ret_code == 0) {
                vdb_msg_SpaceInfo_t* infor = (vdb_msg_SpaceInfo_t*)((char*)pAck);
                {
                    long long total = 0;
                    long long used = 0;
                    long long marked = 0;
                    long long clip = 0;
                    if(pAck->ret_code == 0) {
                        vdb_space_info_t *info = &infor->space_info;
                        total = (long long)info->total_space_hi << 32 | info->total_space_lo;
                        used = (long long)info->used_space_hi << 32 | info->used_space_lo;
                        marked = (long long)info->protected_space_hi << 32 | info->protected_space_lo;
                        clip = (long long)info->clip_space_hi << 32 | info->clip_space_lo;
                    }
                    if(self.spaceDelegate) [self.spaceDelegate onGetCameraSpaceTotal:total free:total-used clip:clip marked:marked];
                }
            } else{
                NSLog(@"VDB_MSG_SpaceInfo get error: %d", pAck->ret_code);
            }
        }
            break;
        case VDB_CMD_SetOptions:
            break;
        default:
            NSLog(@"---unknown cmd result: %d\n", pAck->cmd_code);
            break;
    }
}
- (void)findNewACKHeader {
    NSLog(@"VDB cmd q error, find next cmd header!");
    uint32_t magic = VDB_ACK_MAGIC;
    char* pmagic = (char*)&magic;
    NSData *dmagic = [NSData dataWithBytes:pmagic length:4];
    NSRange totalrange = {0, [self.receivingBuffer length]};
    NSRange newHeader = [self.receivingBuffer rangeOfData:dmagic options:NSDataSearchAnchored range:totalrange];
    if (newHeader.length != 0) {
        NSLog(@"find next cmd, location: %ld", (long)newHeader.location);
        NSRange newbufrange = {0, newHeader.location};
        [self.receivingBuffer replaceBytesInRange:newbufrange withBytes:NULL length:0];
    } else {
        NSLog(@"find no cmd, total length: %ld", (long)[self.receivingBuffer length]);
        NSRange bufrange = {0, [self.receivingBuffer length]};
        [self.receivingBuffer replaceBytesInRange:bufrange withBytes:NULL length:0];
        if ([self.delegate respondsToSelector:@selector(onVDBError:)]) {
            [self.delegate onVDBError:@"find no cmd"];
        }
    }
}

- (void)onReciveBuffer:(nonnull NSData *)data {
    //deal with all cmd in main queue, do not use lock
    [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
        [self.receivingBuffer appendData:data];
        while([self.receivingBuffer length] >= (int)sizeof(vdb_ack_t)) {
            vdb_ack_t *pAck_s = (vdb_ack_t *)[self.receivingBuffer bytes];
            if(pAck_s->magic == VDB_ACK_MAGIC) {
                NSUInteger actLen = pAck_s->extra_bytes + VDB_ACK_SIZE;
                if([self.receivingBuffer length] >= actLen) {
                    NSRange ackrange = {0, actLen};
                    [self onProcessACK:[self.receivingBuffer subdataWithRange:ackrange]];
                    NSRange cmdrange = {0, actLen};
                    [self.receivingBuffer replaceBytesInRange:cmdrange withBytes:NULL length:0];
                } else {
                    break;
                }
            } else {
                [self findNewACKHeader];
            }
        }
    }];
}

- (BOOL)parseGPS:(gpsInfor_t*)gps size:(int)size at:(char*)pointer {
    BOOL ret = YES;
    if (size == sizeof(gps_raw_data_v3_t)) {
        gps_raw_data_v3_t *gpsInfor = (gps_raw_data_v3_t*)pointer;
        gps->longitude = gpsInfor->longitude;
        gps->latitude = gpsInfor->latitude;
        gps->altitude = gpsInfor->altitude;
        gps->speed = gpsInfor->speed;
        gps->orientation = gpsInfor->track;
        gps->hdop = gpsInfor->_hdop;
        gps->vdop = gpsInfor->_vdop;
        gps->absoluteTime = (((uint64_t)gpsInfor->utc_time) * 1000) + (uint64_t)(gpsInfor->utc_time_usec / 1000);
    }
    return ret;
}

- (nullable WLDmsData *)parseDMSDataInBuffer:(char *)bufferPointer bufferSize:(uint32_t)bufferSize {
    eyesight_dms_data_header_t* header = NULL;
    uint32_t leftsize = bufferSize;

    if (leftsize >= sizeof(eyesight_dms_data_header_t)) {
        header = (eyesight_dms_data_header_t*)bufferPointer;
        leftsize -= sizeof(eyesight_dms_data_header_t);
    } else {
        return nil;
    }

    //NSLog(@"dms version: %d", header->version);

    L1OutputV8 *outputV8 = NULL;
    L1OutputV7 *outputV7 = NULL;
    L1OutputV6 *outputV6 = NULL;
    struct L1OutputAll_1_5 *outputV5 = NULL;
    struct L1OutputAll_1_4 *outputV4 = NULL;
    struct L1OutputAll_1_3 *outputV3 = NULL;
    struct L1OutputAll_1_1 *outputV1 = NULL;
    eyesight_person_info_t* person = NULL;

    if (leftsize > 0) {
        if (header->level == 1 && header->revision == 1) {
            if (header->version == 8) {
                char *dynamicPointer = bufferPointer + sizeof(eyesight_dms_data_header_t);

                uint32_t l1outputSize = 0;

                if (read_and_update_pointer(&dynamicPointer, sizeof(uint32_t), &l1outputSize, &leftsize)) {
                    if (sizeof(L1OutputV8) == l1outputSize) {
                        outputV8 = (L1OutputV8 *)malloc(l1outputSize);

                        if (read_and_update_pointer(&dynamicPointer, l1outputSize, outputV8, &leftsize)) {
                            if (header->flags & EYESIGHT_DATA_F_L1_HAS_PERSON_ID) {
                                uint32_t person_size = 0;

                                if (read_and_update_pointer(&dynamicPointer, sizeof(uint32_t), &person_size, &leftsize)) {
                                    if (sizeof(eyesight_person_info_t) == person_size) {
                                        person = (eyesight_person_info_t *)malloc(person_size);

                                        if (!read_and_update_pointer(&dynamicPointer, person_size, person, &leftsize)) {
                                            person = NULL;
                                        }
                                    }
                                    else {
                                        NSLog(@"DMS Data Format Error");
                                    }
                                }
                            }
                        }
                        else {
                            outputV8 = NULL;
                        }
                    }
                    else {
                        NSLog(@"DMS Data Format Error");
                    }
                }
            }
            else if (header->version == 7) {
                char *dynamicPointer = bufferPointer + sizeof(eyesight_dms_data_header_t);

                uint32_t l1outputSize = 0;

                if (read_and_update_pointer(&dynamicPointer, sizeof(uint32_t), &l1outputSize, &leftsize)) {
                    if (sizeof(L1OutputV7) == l1outputSize) {
                        outputV7 = (L1OutputV7 *)malloc(l1outputSize);

                        if (read_and_update_pointer(&dynamicPointer, l1outputSize, outputV7, &leftsize)) {
                            if (header->flags & EYESIGHT_DATA_F_L1_HAS_PERSON_ID) {
                                uint32_t person_size = 0;

                                if (read_and_update_pointer(&dynamicPointer, sizeof(uint32_t), &person_size, &leftsize)) {
                                    if (sizeof(eyesight_person_info_t) == person_size) {
                                        person = (eyesight_person_info_t *)malloc(person_size);

                                        if (!read_and_update_pointer(&dynamicPointer, person_size, person, &leftsize)) {
                                            person = NULL;
                                        }
                                    }
                                    else {
                                        NSLog(@"DMS Data Format Error");
                                    }
                                }
                            }
                        }
                        else {
                            outputV7 = NULL;
                        }
                    }
                    else {
                        NSLog(@"DMS Data Format Error");
                    }
                }
            }
            else if (header->version == 6) {
                char *dynamicPointer = bufferPointer + sizeof(eyesight_dms_data_header_t);

                uint32_t l1outputSize = 0;

                if (read_and_update_pointer(&dynamicPointer, sizeof(uint32_t), &l1outputSize, &leftsize)) {
                    if (sizeof(L1OutputV6) == l1outputSize) {
                        outputV6 = (L1OutputV6 *)malloc(l1outputSize);

                        if (read_and_update_pointer(&dynamicPointer, l1outputSize, outputV6, &leftsize)) {
                            if (header->flags & EYESIGHT_DATA_F_L1_HAS_PERSON_ID) {
                                uint32_t person_size = 0;

                                if (read_and_update_pointer(&dynamicPointer, sizeof(uint32_t), &person_size, &leftsize)) {
                                    if (sizeof(eyesight_person_info_t) == person_size) {
                                        person = (eyesight_person_info_t *)malloc(person_size);

                                        if (!read_and_update_pointer(&dynamicPointer, person_size, person, &leftsize)) {
                                            person = NULL;
                                        }
                                    }
                                    else {
                                        NSLog(@"DMS Data Format Error");
                                    }
                                }
                            }
                        }
                        else {
                            outputV6 = NULL;
                        }
                    }
                    else {
                        NSLog(@"DMS Data Format Error");
                    }
                }
            }
            else if (header->version == 5) {
                char *dynamicPointer = bufferPointer + sizeof(eyesight_dms_data_header_t);

                uint32_t l1outputSize = 0;

                if (read_and_update_pointer(&dynamicPointer, sizeof(uint32_t), &l1outputSize, &leftsize)) {
                    if (sizeof(struct L1OutputAll_1_5) == l1outputSize) {
                        outputV5 = (struct L1OutputAll_1_5 *)malloc(l1outputSize);

                        if (read_and_update_pointer(&dynamicPointer, l1outputSize, outputV5, &leftsize)) {
                            if (header->flags & EYESIGHT_DATA_F_L1_HAS_PERSON_ID) {
                                uint32_t person_size = 0;

                                if (read_and_update_pointer(&dynamicPointer, sizeof(uint32_t), &person_size, &leftsize)) {
                                    if (sizeof(eyesight_person_info_t) == person_size) {
                                        person = (eyesight_person_info_t *)malloc(person_size);

                                        if (!read_and_update_pointer(&dynamicPointer, person_size, person, &leftsize)) {
                                            person = NULL;
                                        }
                                    }
                                    else {
                                        NSLog(@"DMS Data Format Error");
                                    }
                                }
                            }
                        }
                        else {
                            outputV5 = NULL;
                        }
                    }
                    else {
                        NSLog(@"DMS Data Format Error");
                    }
                }
            }
            else {
                if (header->version == 4 && leftsize >= sizeof(struct L1OutputAll_1_4)) {
                    outputV4 = (struct L1OutputAll_1_4*)(bufferPointer + bufferSize - leftsize);
                    leftsize -= sizeof(struct L1OutputAll_1_4);
                } else if (header->version == 3 && leftsize >= sizeof(struct L1OutputAll_1_3)) {
                    outputV3 = (struct L1OutputAll_1_3*)(bufferPointer + bufferSize - leftsize);
                    leftsize -= sizeof(struct L1OutputAll_1_3);
                } else if (header->version == 1 && leftsize >= sizeof(struct L1OutputAll_1_1)) {
                    outputV1 = (struct L1OutputAll_1_1*)(bufferPointer + bufferSize - leftsize);
                    leftsize -= sizeof(struct L1OutputAll_1_1);
                } else {
                    NSLog(@"data too short: %u, version: %u.%u", bufferSize, header->revision, header->version);
                    // unknown version
                }

                if (leftsize != sizeof(eyesight_person_info_t)) {
                    // NSLog(@"Warning, maybe something went wrong, during parsing DMS info!");
                    person = (eyesight_person_info_t*)(bufferPointer + bufferSize - sizeof(eyesight_person_info_t));
                }
                else {
                    person = (eyesight_person_info_t*)(bufferPointer + bufferSize - leftsize);
                }
            }
        }
    }
    
    if (outputV8 != NULL) {
        return [WLDmsDataMapperV8 mapWithHeader:header output:outputV8 personInfo:person];
    }

    if (outputV7 != NULL) {
        return [WLDmsDataMapperV7 mapWithHeader:header output:outputV7 personInfo:person];
    }
    
    if (outputV6 != NULL) {
        return [WLDmsDataMapperV6 mapWithHeader:header output:outputV6 personInfo:person];
    }

    if (outputV5 != NULL) {
        return [WLDmsDataMapperV5 mapWithHeader:header output:outputV5 personInfo:person];
    }

    if (outputV4 != NULL) {
        return [WLDmsDataMapperV4 mapWithHeader:header output:outputV4 personInfo:person];
    }

    if (outputV3 != NULL) {
        return [WLDmsDataMapperV3 mapWithHeader:header output:outputV3 personInfo:person];
    }

    if (outputV1 != NULL) {
        return [WLDmsDataMapperV1 mapWithHeader:header output:outputV1 personInfo:person];
    }

    return [[WLDmsData alloc] initWithDict:[WLDmsDataHeaderMapper mapWithHeader:header]];
}

- (void)onClipUpdate:(vdb_msg_ClipInfo_t*)infor {
    switch (infor->action) {
        case CLIP_ACTION_CHANGED: {
            if (self.clipsDelegate) {
                [self.clipsDelegate onClipUpdate:infor];
            }
            if ((infor->flags & CLIP_ATTR_LIVE) == NO) {
                //changed from app
                [self updateSpaceInfo];
            }
        }
            break;
        case CLIP_ACTION_CREATED: {
            if (self.clipsDelegate) {
                [self.clipsDelegate onClipUpdate:infor];
            }
            if (infor->clip_type == CLIP_TYPE_MARKED) {
                uint32_t clipID = infor->clip_id;
                double time = sTimeFloat(infor->clip_start_time_ms_hi, infor->clip_start_time_ms_lo);
                NSDictionary *userinfo = @{@"clipID":@(clipID),
                                           @"startTime":@(time)};
                NSNotification *noti = [[NSNotification alloc] initWithName:@"Highlight.New.Clip.ID" object:nil userInfo:userinfo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotification:noti];
                });
                //todo, new bookmark
            }
            if ((infor->flags & CLIP_ATTR_LIVE) == NO) {
                //add from app
                [self updateSpaceInfo];
            }
        }
            break;
        case CLIP_ACTION_FINISHED: {
            if (self.clipsDelegate) {
                [self.clipsDelegate onClipUpdate:infor];
            }
            [self updateSpaceInfo];
        }
            break;
        case CLIP_ACTION_MOVED: {
        }
            break;
        case CLIP_ACTION_INSERTED: {
        }
            break;
        default:
            break;
    }
}
@end
