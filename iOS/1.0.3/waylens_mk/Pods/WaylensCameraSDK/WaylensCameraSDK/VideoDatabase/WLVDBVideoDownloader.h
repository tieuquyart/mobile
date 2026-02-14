//
//  WLVDBVideoDownloader.h
//  Vidit
//
//  Created by gliu on 14-6-15.
//  Copyright (c) 2014年 Transee Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLVDBVideoDownloaderDelegate;

@interface WLVDBVideoDownloader: NSObject {
    NSString *_localMp4File;
}
@property (nonatomic, strong) id<WLVDBVideoDownloaderDelegate> delegate;

- (instancetype)initWithURL:(NSString *)url duration:(double)durationInMilliseconds delegate:(id<WLVDBVideoDownloaderDelegate>)delegate;

- (void)cancelTask;
- (NSString *)getFileURL;
- (double)currentProgress;

@end

@protocol WLVDBVideoDownloaderDelegate <NSObject>

- (void)vdbVideoDownloader:(WLVDBVideoDownloader *)vdbVideoDownloader onDownloadProcess:(int)process;

@optional
- (void)vdbVideoDownloader:(WLVDBVideoDownloader *)vdbVideoDownloader onDownloadedBytes:(int64_t)bytes;

@end
