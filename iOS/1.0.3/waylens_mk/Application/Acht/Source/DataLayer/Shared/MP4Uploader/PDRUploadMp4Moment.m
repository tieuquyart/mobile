//
//  PDRUploadMp4Moment.m
//  Hachi
//
//  Created by Waylens Administrator on 11/3/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "PDRUploadMp4Moment.h"
#import "MP4Uploader.h"

@import AssetsLibrary;
@import Foundation;

@implementation MP4File

-(instancetype)initWithURL:(NSURL *)url{
    self = [super init];
    if (self) {
        self.sourceUrl = url;
        if (url) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:url];
            [[[MP4Uploader alloc] init] prepareMp4file:self withAsset:asset];
        }
    }
    return self;
}

-(NSData *)mp4data{
    if (!_mp4data && self.sourceUrl) {
        NSError *error;
        _mp4data = [NSData dataWithContentsOfFile:self.sourceUrl.path options:NSDataReadingUncached error:&error];
        if (error)
            NSLog(@"mp4file %@ create data error:%@", self.sourceUrl.path, error);
    }
    return _mp4data;
}

-(unsigned long long)size{
    if (!_size) {
        if (_mp4data) {
            _size = _mp4data.length;
        } else if (_sourceUrl) {
            _size = [[NSFileManager defaultManager] attributesOfItemAtPath:_sourceUrl.path error:nil].fileSize;
        }
    }
    return _size;
}

@end


@implementation PDRUploadMp4Moment

-(NSMutableDictionary *)dict {
    NSMutableDictionary *dict = [super dict];
    dict[@"momentType"] = self.momentType;
    return dict;
}

-(void)setMp4Url:(NSURL *)url{
    if (!url) {
        self.mp4file = nil;
    } else {
        self.mp4file  = [[MP4File alloc] initWithURL:url];
    }
}

- (unsigned long long)totalSize {
    return self.mp4file.size;
}

-(NSString *)momentType{
    return @"NORMAL_SINGLE";
}

@end
