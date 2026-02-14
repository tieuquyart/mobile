//
//  PDRUploadMp4Moment.h
//  Hachi
//
//  Created by Waylens Administrator on 11/3/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PDRUploadMoment.h"
#import "VideoResolutionUtil.h"

@interface MP4File : NSObject
@property (strong, nonatomic) NSURL *sourceUrl;
@property (strong, nonatomic) NSData *mp4data;
@property (assign, nonatomic) unsigned long long size;
@property (assign, nonatomic) MP4Resolution resolution;
@property (assign, nonatomic) long long duration;
@end

@interface PDRUploadMp4Moment : PDRUploadMoment
@property (strong, nonatomic) MP4File *mp4file;
-(void)setMp4Url:(NSURL *)url;
@end
