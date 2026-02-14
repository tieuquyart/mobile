//
//  DMSClient.h
//  Acht
//
//  Created by gliu on 1/4/20.
//  Copyright © 2020 waylens. All rights reserved.
//

#import "WLSocketClient.h"
#import "WLDefine.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, DMSClientError) {
    DMSErrOK = 0,
    DMSErrNoServer = -1,
    DMSErrInternal = -2,
    DMSErrNoFace = -3,
};

@protocol WLDmsClientDelegate;

@interface WLDmsClient: WLSocketClient
@property (weak, nonatomic, nullable) id<WLDmsClientDelegate> dmsDelegate;
@property (assign, nonatomic) uint32_t vendor;

- (void)calibrateWithX:(float)x y:(float)y z:(float)z completionHandler:(nullable WLDmsCameraCalibrateCompletionHandler)completionHandler;

- (void)getVersion;
- (void)getAllFaces;
- (void)addFaceWithID:(unsigned long long)faceID name:(NSString *)name;
- (void)removeFaceWithID:(unsigned long long)faceID;
- (void)removeAllFaces;
@end

@protocol WLDmsClientDelegate
- (void)dmsClient:(WLDmsClient *)dmsClient didGetFaceList:(NSArray<NSDictionary*>*)list;
- (void)dmsClient:(WLDmsClient *)dmsClient didAddFaceWithResult:(int)result;
- (void)dmsClient:(WLDmsClient *)dmsClient didRemoveFaceWithResult:(int)result;
- (void)dmsClient:(WLDmsClient *)dmsClient didRemoveAllFaceWithResult:(int)result;
@end

NS_ASSUME_NONNULL_END

