//
//  MP4Uploader.h
//  Hachi
//
//  Created by lzhu on 10/21/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDRUploadMp4Moment.h"

typedef void(^FinishBlock)(BOOL done, NSError* err, NSDictionary* msg);
typedef void(^ProcessBlock)(BOOL done, NSError* err, NSDictionary* msg, float process);

@class AVURLAsset;

@interface MP4Uploader : NSObject

- (void)uploadMP4Moment:(PDRUploadMp4Moment *)moment toBaseUrl:(NSString *)baseUrl privateKey:(NSString *)privateKey userId:(NSString *)userId progress:(ProcessBlock)progressBlock completion:(FinishBlock)completionBlock;
- (void)prepareMp4file:(MP4File *)mp4file withAsset:(AVURLAsset *)asset;
- (void)cancel;

@end
