//
//  DMSClient.h
//  Acht
//
//  Created by gliu on 1/4/20.
//  Copyright © 2020 waylens. All rights reserved.
//

#import "TSClient.h"

typedef NS_ENUM(int, DMSClientError) {
    DMSErrOK = 0,
    DMSErrNoServer = -1,
    DMSErrInternal = -2,
    DMSErrNoFace = -3,
};
@protocol DMSClientDelegate

//- onGetVersion:(int)vendor;
- (void)onGetFaceList:(NSArray<NSDictionary*>*)list;
- (void)onAddFaceResult:(int)result;
- (void)onRemoveFaceResult:(int)result;
- (void)onRemoveAllFaceResult:(int)result;
- (void)onCalibResult:(int)result;

@end

@interface DMSClient : TSClient {
    unsigned long long addID;
    NSString* addName;
}

@property (assign, nonatomic) uint32_t vendor;
//@property (assign, nonatomic) NSArray* faceList;

@property (weak, nonatomic) id<DMSClientDelegate>   dmsDelegate;

// api
- (void)getVersion;
- (void)getAllFaces;
- (void)addFaceWithID:(unsigned long long)faceID name:(NSString*)name;
- (void)removeFaceWithID:(unsigned long long)faceID;
- (void)removeAllFaces;
- (void)doCalibWithX:(float)x Y:(float)y Z:(float)z;

- (void)setOnRoadDirection;

@end

