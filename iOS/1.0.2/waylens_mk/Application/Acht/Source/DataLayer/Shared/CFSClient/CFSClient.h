//
//  CFSClient.h
//  Hachi
//
//  Created by Waylens Administrator on 8/19/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CFS_API_VERSION @"v.1.0"
#define CFS_UPLOAD_AVATAR @"upload_avatar"
#define CFS_UPLOAD_VIDEO @"upload_videos"
#define CFS_UPLOAD_PICTURE @"upload_picture"
#define CFS_UPLOAD_RESOURCE @"upload_resource"

typedef void(^FinishBlock)(BOOL done, NSError* err, NSDictionary* msg);
typedef void(^ProcessBlock)(BOOL done, NSError* err, NSDictionary* msg, float process);

@class PDRUploadMp4Moment;

@interface CFSClient : NSObject
- (instancetype)initWithBaseUrl:(NSString *)baseUrl privateKey:(NSString *)privateKey userId:(NSString *)userId;
-(void)uploadAvatar:(NSData *)data  progress:(ProcessBlock)progressBlock completion:(FinishBlock)completion;
-(void)stop;
-(BOOL)isUploading;

- (void)uploadMP4Moment:(PDRUploadMp4Moment *)moment progress:(ProcessBlock)progressBlock completion:(FinishBlock)completion;

@end
