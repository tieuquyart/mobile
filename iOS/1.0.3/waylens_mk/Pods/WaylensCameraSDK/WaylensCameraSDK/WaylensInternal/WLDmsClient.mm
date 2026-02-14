//
//  DMSClient.m
//  Acht
//
//  Created by gliu on 1/4/20.
//  Copyright © 2020 waylens. All rights reserved.
//

#include "dms_ipc.h"
#import "WLDmsClient.h"

#define NewCmdBuffer(a) char a[DMS_CMD_SIZE]; memset(a, 0, DMS_CMD_SIZE);

@interface WLDmsClient()
@property (readwrite, nonatomic, copy) WLDmsCameraCalibrateCompletionHandler calibrateCompletionHandler;
@end

@implementation WLDmsClient {
    unsigned long long addID;
    NSString* addName;
}

- (nonnull instancetype)initWithIPv4:(nullable NSString *)ipv4 IPv6:(nullable NSString *)ipv6 port:(long)port carrier:(nullable NSString *)carrier {
    self = [super initWithIPv4:ipv4 IPv6:ipv6 port:port];
    _vendor = 0;
    if (self) {
        if(isatty(STDOUT_FILENO)) {
            self.heartBeatInterval = 4;
            //self.heatBeatInterval = 4;
        } else {
            self.heartBeatInterval = 4;
        }
        [self sendHeartBeat];
    }
    return self;
}

- (void)getVersion {
    NewCmdBuffer(tmp)
    dms_cmd_GetVersionInfo_t* cmd = (dms_cmd_GetVersionInfo_t*)tmp;
    cmd->header.cmd_code = DMS_CMD_GetVersionInfo;
    [self sendData:tmp];
}
- (void)getAllFaces {
    NewCmdBuffer(tmp)
    dms_cmd_ListFaceIds_t* cmd = (dms_cmd_ListFaceIds_t*)tmp;
    cmd->header.cmd_code = DMS_CMD_ListFaceIds;
    [self sendData:tmp];
}

- (void)addFaceWithID:(unsigned long long)faceID name:(nonnull NSString *)name {
    addID = faceID;
    addName = [name copy];
    NewCmdBuffer(tmp)
    if (_vendor == VENDOR_READSENSE) {
        rs_cmd_CaptureImage_t* cmd = (rs_cmd_CaptureImage_t*)tmp;
        cmd->header.cmd_code = RS_CMD_CaptureImage;
        [self sendData:tmp];
    } else if (_vendor == VENDOR_EYESIGHT) {
        es_cmd_StartUserEnrollment_t* cmd = (es_cmd_StartUserEnrollment_t*)tmp;
        cmd->header.cmd_code = ES_CMD_StartUserEnrollment;
        cmd->faceid_hi = addID >> 32;
        cmd->faceid_lo = addID & 0xffffffff;
        ::strcpy((char*)&(cmd->name[0]), [addName cStringUsingEncoding:NSUTF8StringEncoding]);
        [self sendData:tmp];

    } else {
        if (self.dmsDelegate) {
            [self.dmsDelegate dmsClient:self didAddFaceWithResult:DMSErrNoServer];
        }
    }
}

- (void)doAddFaceReadSense {
    NewCmdBuffer(tmp)
    rs_cmd_AddFaceId_t* cmd = (rs_cmd_AddFaceId_t*)tmp;
    cmd->header.cmd_code = RS_CMD_AddFaceId;
    cmd->faceid_hi = addID >> 32;
    cmd->faceid_lo = addID & 0xffffffff;
    ::strcpy((char*)&(cmd->name[0]), [addName cStringUsingEncoding:NSUTF8StringEncoding]);
    [self sendData:tmp];
}
- (void)removeFaceWithID:(unsigned long long)faceID {
    NewCmdBuffer(tmp)
    dms_cmd_RemoveFaceId_t* cmd = (dms_cmd_RemoveFaceId_t*)tmp;
    cmd->header.cmd_code = DMS_CMD_RemoveFaceId;
    cmd->header.cmd_tag = 0;
    cmd->faceid_hi = faceID >> 32;
    cmd->faceid_lo = faceID & 0xffffffff;
    cmd->remove_all = 0;
    [self sendData:tmp];
}
- (void)removeAllFaces {
    NewCmdBuffer(tmp)
    dms_cmd_RemoveFaceId_t* cmd = (dms_cmd_RemoveFaceId_t*)tmp;
    cmd->header.cmd_code = DMS_CMD_RemoveFaceId;
    cmd->header.cmd_tag = 1;
    cmd->faceid_hi = 0;
    cmd->faceid_lo = 0;
    cmd->remove_all = 1;
    [self sendData:tmp];
}

- (void)calibrateWithX:(float)x y:(float)y z:(float)z completionHandler:(WLDmsCameraCalibrateCompletionHandler)completionHandler {
    self.calibrateCompletionHandler = completionHandler;

    NewCmdBuffer(tmp)
    es_cmd_EstimateCameraPose_t* cmd = (es_cmd_EstimateCameraPose_t*)tmp;
    cmd->header.cmd_code = ES_CMD_EstimateCameraPose;
    cmd->objectLocationVcs.x = x;
    cmd->objectLocationVcs.y = y;
    cmd->objectLocationVcs.z = z;
    [self sendData:tmp];
}

#pragma mark -- private
- (void)sendHeartBeat {
    [self getVersion];
}
- (BOOL)sendData:(char*)cmd {
    ((dms_cmd_GetVersionInfo_t*)cmd)->header.user1 = 0;
    NSData* pdata = [NSData dataWithBytes:cmd length:DMS_CMD_SIZE];
    [self sendData:pdata withTimeout:5];
    return YES;
}


#pragma mark -- receive
- (void)onProcessACK:(NSData*)ack {
    dms_ipc_ack_header_t *pAck = (dms_ipc_ack_header_t *)[ack bytes];
    // do not call here
    //if(pAck->cmd_code != VDB_MSG_ClipInfo && pAck->cmd_code != VDB_MSG_RawData) NSLog(@"VDBClient Receive CMD:%d", pAck->cmd_code);
    switch (pAck->cmd_code) {
        case DMS_CMD_GetVersionInfo: {
            if(pAck->ret_code == 0) {
                dms_ack_GetVersionInfo_t* ver = (dms_ack_GetVersionInfo_t*)(pAck + 1);
                _vendor = ver->vendor;
            } else{
                NSLog(@"DMS_CMD_GetVersionInfo get error: %d", pAck->ret_code);
            }
        }
            break;
        case DMS_CMD_ListFaceIds: {
            if(pAck->ret_code == 0) {
                dms_ack_ListFaceIds_t* list = (dms_ack_ListFaceIds_t*)(pAck + 1);
                NSMutableArray* arr = [NSMutableArray new];

                dms_face_item_t* items = (dms_face_item_t*)(list + 1);
                if (list->num_ids > 0) {
                    for (int i = 0; i < list->num_ids; i++) {
                        char* name = (char*)items->name;
                        NSDictionary* dict = [NSDictionary dictionaryWithObjects:@[@(items->faceid_hi),
                                                                                   @(items->faceid_lo),
                                                                                   [NSString stringWithCString:name encoding:NSASCIIStringEncoding]]
                                                                         forKeys:@[@"faceid_hi", @"faceid_lo", @"name"]];
                        [arr addObject:dict];
                        items++;
                    }
                }
                if (self.dmsDelegate) {
                    [self.dmsDelegate dmsClient:self didGetFaceList:arr];
                }
            } else{
                NSLog(@"DMS_CMD_ListFaceIds get error: %d", pAck->ret_code);
            }
        }
            break;
        case RS_CMD_CaptureImage: {
            if(pAck->ret_code == 0) {
                rs_ack_CaptureImage_t* img = (rs_ack_CaptureImage_t*)(pAck + 1);
                if (img->has_face == false) {
                    if (self.dmsDelegate) {
                        [self.dmsDelegate dmsClient:self didAddFaceWithResult:DMSErrNoFace];
                    }
                    break;
                } else {
                    [self doAddFaceReadSense];
                }
            } else{
                NSLog(@"RS_CMD_CaptureImage get error: %d", pAck->ret_code);
                if (self.dmsDelegate) {
                    [self.dmsDelegate dmsClient:self didAddFaceWithResult:DMSErrInternal];
                }
            }
        }
        break;
        case RS_CMD_AddFaceId: {
            if(pAck->ret_code == 0) {
                NSLog(@"RS_CMD_AddFaceId Success!");
                if (self.dmsDelegate) {
                    [self.dmsDelegate dmsClient:self didAddFaceWithResult:DMSErrOK];
                }
            } else{
                NSLog(@"RS_CMD_AddFaceId get error: %d", pAck->ret_code);
                if (self.dmsDelegate) {
                    [self.dmsDelegate dmsClient:self didAddFaceWithResult:DMSErrInternal];
                }
            }
        }
            break;
//        case ES_CMD_StartUserEnrollment: {
//            if(pAck->ret_code == 0) {
//                NSLog(@"ES_CMD_StartUserEnrollment Success!");
//                if (self.dmsDelegate) {
//                    [self.dmsDelegate dmsClient:self didAddFaceWithResult:DMSErrOK];
//                }
//            } else{
//                NSLog(@"ES_CMD_StartUserEnrollment get error: %d", pAck->ret_code);
//                if (self.dmsDelegate) {
//                    [self.dmsDelegate dmsClient:self didAddFaceWithResult:DMSErrInternal];
//                }
//            }
//        }
//            break;
        case ES_MSG_UserEnrollment: {
            if(pAck->ret_code == 0) {
                NSLog(@"ES_MSG_UserEnrollment Success!");
                if (self.dmsDelegate) {
                    [self.dmsDelegate dmsClient:self didAddFaceWithResult:DMSErrOK];
                }
            } else{
                NSLog(@"ES_MSG_UserEnrollment error: %d", pAck->ret_code);
                if (self.dmsDelegate) {
                    [self.dmsDelegate dmsClient:self didAddFaceWithResult:DMSErrInternal];
                }
            }
        }
            break;
        case DMS_CMD_RemoveFaceId: {
            NSLog(@"DMS_CMD_RemoveFaceId[%u] ret_code: %d", pAck->cmd_tag, pAck->ret_code);
            if (pAck->cmd_tag == 0) {
                if (self.dmsDelegate) {
                    [self.dmsDelegate dmsClient:self didRemoveFaceWithResult:(pAck->ret_code!=0) ? DMSErrInternal : DMSErrOK];
                }
            } else  {
                if (self.dmsDelegate) {
                    [self.dmsDelegate dmsClient:self didRemoveAllFaceWithResult:(pAck->ret_code!=0) ? DMSErrInternal : DMSErrOK];
                }
            }
        }
            break;
        case ES_CMD_EstimateCameraPose: {
            NSLog(@"ES_CMD_EstimateCameraPose ret_code: %d", pAck->ret_code);
            if (self.calibrateCompletionHandler) {
                BOOL success = (pAck->ret_code == 0 ? YES : NO);
                self.calibrateCompletionHandler(success);
            }
        }
            break;
        default:
            NSLog(@"---unknown DMS cmd code: %d\n", pAck->cmd_code);
            break;
    }
}
- (void)findNewACKHeader {
    NSLog(@"DMS cmd q error, find next cmd header!");
    uint32_t magic = DMS_ACK_MAGIC;
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
//        if ([self.delegate respondsToSelector:@selector(onVDBError:)]) {
//            [self.delegate onVDBError:@"find no cmd"];
//        }
    }
}

- (void)onReciveBuffer:(nonnull NSData *)data {
    //deal with all cmd in main queue, do not use lock
    [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
        [self.receivingBuffer appendData:data];
        while([self.receivingBuffer length] >= (int)sizeof(dms_ipc_ack_header_t)) {
            dms_ipc_ack_header_t *pAck_s = (dms_ipc_ack_header_t *)[self.receivingBuffer bytes];
            if(pAck_s->magic == DMS_ACK_MAGIC) {
                NSUInteger actLen = pAck_s->extra_bytes + DMS_ACK_SIZE;
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
@end
