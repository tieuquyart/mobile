//
//  WLCameraLogDownloader.h
//  Acht
//
//  Created by gliu on 10/31/17.
//  Copyright © 2017 waylens. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WLCameraLogDownloaderDelegate;

@interface WLCameraLogDownloader: NSObject
@property (weak, nonatomic, nullable) id<WLCameraLogDownloaderDelegate> delegate;
@property (strong, nonatomic, nullable) NSURL *fileUrl;

- ( instancetype)initWithIP:(NSString *)ip port:(long)port;
- (void)downloadToFile:(NSURL *)file;
- (void)cancel;

@end

@protocol WLCameraLogDownloaderDelegate
-(void)cameraLogDownloader:(WLCameraLogDownloader *)cameraLogDownloader downloadProgressDidChange:(float)progress;
-(void)cameraLogDownloader:(WLCameraLogDownloader *)cameraLogDownloader downloadFinished:(BOOL)finished error:(nullable NSError *)error;
@end

NS_ASSUME_NONNULL_END
