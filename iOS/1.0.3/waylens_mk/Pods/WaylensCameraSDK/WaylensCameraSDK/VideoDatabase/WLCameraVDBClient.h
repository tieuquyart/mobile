//
//  CameraVDBClient.h
//  Vidit
//
//  Created by gliu on 15/1/13.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "WLSocketClient.h"
#import "WLVDBClip.h"
#import "WLVDBThumbnail.h"
#import "WLDefine.h"

#define MaxCanbeIgnoreImgNum 2000

#define VDBClientDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

typedef enum VDBDomain {
    VDBDomain_Album     = CLIP_TYPE_BUFFER,
    VDBDomain_Mark      = CLIP_TYPE_MARKED,
    VDBDomain_Playlist1 = CLIP_TYPE_PLIST0,
    VDBDomain_PlaylistEnd = CLIP_TYPE_PLIST0 + NUM_PLISTS,
    //VDBDomain_Playlist2 = CLIP_TYPE_PLIST1,
    //VDBDomain_Playlist3 = CLIP_TYPE_PLIST2,
    VDBDomain_End       = 0x4fff,
} WLVDBDomain;

NS_ASSUME_NONNULL_BEGIN

@class WLDmsData;

@protocol WLCameraLiveDelegate <NSObject>
@optional
- (void)onLiveOBD:(NSData *)data;
- (void)onLiveACC:(NSData *)data;
- (void)onLiveGPS:(NSData *)data;
- (void)onLiveDMS:(nullable WLDmsData *)dmsData;
@end

@protocol WLVDBDynamicRequestDelegate <NSObject>
@optional
- (void)onGetPlayURL:(nullable NSString *)url time:(double)time tag:(int)tag;
- (void)onGetClipExtent:(vdb_ack_GetClipExtent_t *)clipExtent;
- (void)onSetClipExtentResult:(int)result;
- (void)onGetTSUrl:(nullable NSString *)url tag:(int)tag;
- (void)onClipMark:(BOOL)done;

- (void)onGpsInforUpdate:(gpsInfor_t *)infor inDomain:(WLVDBDomain)domain;
- (void)onOBDData:(NSData *)data time:(double)time clip:(int)clip inDomain:(WLVDBDomain)domain;
- (void)onGSensorData:(acc_raw_data_t *)data time:(double)time clip:(int)clip inDomain:(WLVDBDomain)domain;
- (void)onIIOData:(iio_raw_data_t *)data time:(double)time clip:(int)clip inDomain:(WLVDBDomain)domain;
- (void)onDMSData:(nullable readsense_dms_data_v2_t *)data time:(double)time clip:(int)clip inDomain:(WLVDBDomain)domain withRecordConfig:(NSString *)config;
- (void)onDMSESData:(nullable WLDmsData *)dmsData
               time:(double)time
               clip:(int)clip
           inDomain:(WLVDBDomain)domain
   withRecordConfig:(NSString *)config;
- (void)onVDBError:(NSString *)error;
@end

@protocol WLVDBRequestDelegate <NSObject>
- (void)onGetThumbnail:(WLVDBThumbnail *)thumbnail;
- (void)onGetDownloadURL:(nullable NSString *)mainurl mainsize:(double)mainsizek
                     sub:(nullable NSString *)subUrl subsize:(double)subsizek
                    subn:(nullable NSString *)subnUrl subnsize:(double)subnsizek
                    date:(NSDate *)mainDate length:(unsigned int)length tag:(uint32_t)tag;
- (void)onGetGpsData:(gpsInfor_t)info inDomain:(WLVDBDomain)domain tag:(uint32_t)tag;
@end

@interface WLCameraVDBClient: WLSocketClient

@property (weak, nonatomic) id<WLVDBDynamicRequestDelegate> delegate;
@property (weak, nonatomic) id<WLCameraLiveDelegate> liveDelegate;
@property (weak, nonatomic) id<WLVDBRequestDelegate> requestDelegate;

- (void)getThumbnailForClip:(int)clipid inDomain:(WLVDBDomain)domain atTime:(double)point tag:(uint32_t)tag canBeIgnore:(BOOL)canIgnore withID:(nullable WLVDBID *)vdbid useCache:(BOOL)useCache;
- (void)getDownloadURLForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)length main:(BOOL)bmain sub:(BOOL)bsub subn:(int)subn tag:(uint32_t)tag;

- (BOOL)getHLSForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)sec stream:(int)main withTag:(long)tag andID:(nullable WLVDBID *)vdbid;
- (BOOL)getMP4ForClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)sec stream:(int)main withTag:(long)tag andID:(nullable WLVDBID *)vdbid;

- (void)getExtraRawDataForClip:(int)clipid inDomain:(WLVDBDomain)domain atTime:(double)point withIndexes:(int32_t)types withID:(nullable WLVDBID *)vdbid;
- (void)getRawDataWithACC:(BOOL)acc GPS:(BOOL)gps OBD:(BOOL)obd forClip:(int)clipId inDomain:(WLVDBDomain)domain atTime:(double)point tag:(uint32_t)tag withVDBId:(nullable WLVDBID *)vdbId;

//for album or mark
- (void)removeClip:(int)clipid inDomain:(WLVDBDomain)domain withID:(nullable WLVDBID *)vdbid;
- (void)markClip:(int)clipid inDomain:(WLVDBDomain)domain from:(double)point length:(double)sec withID:(nullable WLVDBID *)vdbid;

@end

NS_ASSUME_NONNULL_END
