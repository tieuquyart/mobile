//
//  WLVDBVideoDownloader.mm
//  Vidit
//
//  Created by gliu on 14-6-15.
//  Copyright (c) 2014年 Transee Design. All rights reserved.
//

#import "avflib.h"
#import "WLVDBVideoDownloader.h"
#import <pthread.h>
#import <WaylensFoundation/WaylensFoundation.h>
#import "WLVDBVideoDownloader+FrameworkInternal.h"

static void muxerCallBack(void *context, int event, int arg1, int arg2) {
    WLVDBVideoDownloader* p = (__bridge WLVDBVideoDownloader*)context;
    [p OnRemuxerEvent:event para1:arg1 para2:arg2];
}

@interface WLVDBVideoDownloader () {
    avf_remuxer_t       *_pRemuxer;
    dispatch_queue_t queue;
}
@property (nonatomic, strong) WLTimer *timer;
@end

@implementation WLVDBVideoDownloader

- (instancetype)initWithURL:(NSString *)url duration:(double)durationInMilliseconds delegate:(id<WLVDBVideoDownloaderDelegate>)delegate {
    return [self initWithURL:url duration:durationInMilliseconds sequency:0 IOnly:false Silent:false AudioFile:nil setDelegate:delegate];
}

-(id)initWithURL:(NSString*)url
        duration:(double)ms
        sequency:(long long)seq
           IOnly:(BOOL)ionly
          Silent:(BOOL)bSilent
       AudioFile:(NSString*)audioName
     setDelegate:(id<WLVDBVideoDownloaderDelegate>)del
{
    self = [super init];
    if(self) {
        int rt = -1;
        _delegate = del;
        _pRemuxer   = avf_remuxer_create(muxerCallBack, (__bridge void *)self);
        if(_pRemuxer) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
            if(basePath) {
                _localMp4File = [basePath stringByAppendingFormat:@"/waylens%lld.mp4", seq];
                BOOL rr = [self removeLocalFile];
                if(rr) {
                    if (ionly) {
                        avf_remuxer_set_iframe_only(_pRemuxer, 1);
                    }
                    if (bSilent) {
                        avf_remuxer_set_audio(_pRemuxer, 1, nil, nil);
                    } else if (audioName != nil) {
                        avf_remuxer_set_audio_fade_ms(_pRemuxer, ms > 1000 ? 1000 : ms / 2);
                        avf_remuxer_set_audio(_pRemuxer, 0, [audioName cStringUsingEncoding:NSUTF8StringEncoding], "mp4");
                    }
                    rt = avf_remuxer_run(_pRemuxer,
                                         [url cStringUsingEncoding:NSASCIIStringEncoding],
                                         "ts",
                                         [_localMp4File cStringUsingEncoding:NSASCIIStringEncoding],
                                         "mp4",
                                         ms);
                    __weak typeof(self) weakself = self;
                    _timer = [[WLTimer alloc] initWithReference:self interval:0.2 repeat:true block:^{
                        [weakself checkProgress];
                    }];
                }
            }
            else{
                NSLog(@"++++++ empty path");
            }
        }
        if (_delegate != Nil){
            [_delegate vdbVideoDownloader:self onDownloadProcess:rt];
        }
        queue = dispatch_queue_create("com.waylens.vdbvideodownloader", DISPATCH_QUEUE_SERIAL);
        [self.timer start];
    }
    return self;
}

-(void)cancelTask {
    [self DestroyTask];
}
-(void)DestroyTask {
    [self.timer stop];
    dispatch_async(queue, ^{
        if(self->_pRemuxer != nil) {
            avf_remuxer_destroy(self->_pRemuxer);
            NSLog(@"avf_remuxer_destroy %p", self->_pRemuxer);
            self->_pRemuxer = nil;
        }
    });
}
-(NSString*)getFileURL {
    return _localMp4File;
}
- (BOOL) removeLocalFile {
    BOOL ret = YES;
    if([[NSFileManager defaultManager]  fileExistsAtPath:_localMp4File ]) {
        ret = [[NSFileManager defaultManager] removeItemAtPath:_localMp4File error:Nil];
        NSLog(@"removefile : %d", ret);
    }
    return ret;
}

-(void)checkProgress {
    dispatch_async(queue, ^{
        if (self->_pRemuxer == nil) {
            return;
        }
        uint64_t totalBytes = 0;
        uint64_t remainingBytes = 1;
        avf_remuxer_get_progress(self->_pRemuxer, &totalBytes, &remainingBytes);
        int64_t bytes = totalBytes - remainingBytes;
        if (bytes >= 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(vdbVideoDownloader:onDownloadedBytes:)]) {
                    [self.delegate vdbVideoDownloader:self onDownloadedBytes:bytes];
                }
            });
        }
    });
}

- (double)currentProgress {
    __block uint64_t totalBytes = 0;
    __block uint64_t remainingBytes = 0;
    dispatch_sync(queue, ^{
        if (_pRemuxer == nil) {
            return;
        }
        avf_remuxer_get_progress(_pRemuxer, &totalBytes, &remainingBytes);
    });
    if (totalBytes > 0) {
        return double(totalBytes - remainingBytes)/double(totalBytes);
    } else {
        return 0;
    }
}

-(void)OnRemuxerEvent:(int)event para1:(int) arg1 para2:(int)arg2 {
    if (_pRemuxer == nil) return;
    switch (event) {
        case AVF_REMUXER_FINISHED: {
            [self DestroyTask];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate vdbVideoDownloader:self onDownloadProcess:200];
            });
        }
            break;
        case AVF_REMUXER_ERROR: {
            [self DestroyTask];
            NSLog(@"muxer error : %d,  %d", arg1, arg2);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate vdbVideoDownloader:self onDownloadProcess:-2];
            });
        }
            break;
        case AVF_REMUXER_PROGRESS: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate vdbVideoDownloader:self onDownloadProcess:arg1];
            });
        }
            break;
        default:
            break;
    }
}
@end
