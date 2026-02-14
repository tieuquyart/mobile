//
//  MP4Uploader.m
//  Hachi
//
//  Created by lzhu on 10/21/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "MP4Uploader.h"
#import "CFSClient.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "VideoResolutionUtil.h"
#import "PDRUploadMp4Moment.h"
#import <UIKit/UIKit.h>

@interface MP4Uploader()
@property (assign, nonatomic) BOOL converted;
@property (copy, nonatomic) ProcessBlock progressBlock;
@property (copy, nonatomic) FinishBlock completionBlock;
@property (strong, nonatomic) AVAssetExportSession *session;
@property (strong, nonatomic) CFSClient *cfs;
@property (strong, nonatomic) PDRUploadMp4Moment *moment;
@property (strong, nonatomic) AVURLAsset *asset;
@end

@implementation MP4Uploader

- (void)uploadMP4Moment:(PDRUploadMp4Moment *)moment toBaseUrl:(NSString *)baseUrl privateKey:(NSString *)privateKey userId:(NSString *)userId progress:(ProcessBlock)progressBlock completion:(FinishBlock)completionBlock {
    self.cfs = [[CFSClient alloc] initWithBaseUrl:baseUrl privateKey:privateKey userId:userId];
    self.moment = moment;
    self.progressBlock = progressBlock;
    self.completionBlock = completionBlock;
    self.converted = NO;
    [self prepareAndUpload];
}

-(AVURLAsset *)asset{
    if (!_asset) {
//        _asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.moment.mp4file.sourceUrl.path] options:nil];
        _asset = [AVURLAsset assetWithURL:self.moment.mp4file.sourceUrl];
    }
    return _asset;
}

-(void)prepareAndUpload{
    if(![[self.moment.mp4file.sourceUrl absoluteString] hasSuffix:@".mp4"]) {
        NSLog(@"MP4: The asset is not MP4, convert to MP4...");
        NSInteger degree = [self rotationDegreeOfVideo:self.asset];
        if(degree == 0) {
            [self convertToMP4];
        } else {
            NSLog(@"MP4 : Fix rotation issue...");
            [self rotateVideo];
        }
        self.converted = YES;
    } else {
        [self startUploading];
    }
}

- (void) convertToMP4 {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.moment.mp4file.sourceUrl options:nil];
    NSString *exportPath = [self exportedFilePath];
    [self removeFileAtPath:exportPath];
    self.moment.mp4file.sourceUrl = [NSURL fileURLWithPath:exportPath];
    self.asset = nil;
    self.session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    self.session.outputURL = self.moment.mp4file.sourceUrl;
    self.session.outputFileType = AVFileTypeMPEG4;
    self.session.shouldOptimizeForNetworkUse = YES;
    [self startExporting];
}

- (NSString*) exportedFilePath {
    NSString *docpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/converted.mp4", docpath];
}

- (void) startExporting {
    [self.session exportAsynchronouslyWithCompletionHandler:^{
        switch([self.session status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"MP4: Export to MP4 failed:%@", [[self.session error] localizedDescription]);
                if (self.completionBlock != nil) {
                    self.completionBlock(NO, self.session.error, nil);
                }
                [self clear];
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"MP4: Export to MP4 canceled");
                if (self.completionBlock != nil) {
                    self.completionBlock(NO, self.session.error, nil);
                }
                [self clear];
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"MP4: Export to MP4 success");
                UISaveVideoAtPathToSavedPhotosAlbum([self filePathOfURL:self.moment.mp4file.sourceUrl], nil, nil, nil);
                [self startUploading];
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"MP4: Exportimg progress : %@", @(self.session.progress));
                break;
            default:
                break;
        }
    }];
}

- (void) rotateVideo {
    AVURLAsset *asset = self.asset;
    AVAssetTrack *videoTrack = nil, *audioTrack = nil;
    if([asset tracksWithMediaType:AVMediaTypeAudio].count) {
        audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    if([asset tracksWithMediaType:AVMediaTypeVideo].count) {
        videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    if(videoTrack) {
        AVMutableCompositionTrack *cvTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [cvTrack insertTimeRange:(CMTimeRange){kCMTimeZero, asset.duration} ofTrack:videoTrack atTime:insertionPoint error:&error];
        if(error) {
            NSLog(@"MP4: Error %@", error);
        }
    }
    if(audioTrack) {
        AVMutableCompositionTrack *caTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [caTrack insertTimeRange:(CMTimeRange){kCMTimeZero, asset.duration} ofTrack:audioTrack atTime:insertionPoint error:&error];
        if(error) {
            NSLog(@"MP4: Error %@", error);
        }
    }
    CGAffineTransform transform = [self transformOfVideo:asset];
    NSInteger degree = [self rotationDegreeOfVideo:asset];
    CGSize size = videoTrack.naturalSize;
    if(degree == 90 || degree == 270) {
        size = CGSizeMake(size.height, size.width);
    }
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = size;//videoTrack.naturalSize;
    NSLog(@"MP4: Rotation %@, Natural size %@",@(degree), NSStringFromCGSize(size));
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:composition.tracks[0]];
    [layerInstruction setTransform:transform atTime:kCMTimeZero];
    
    instruction.layerInstructions = @[layerInstruction];
    videoComposition.instructions = @[instruction];

    NSString *exportPath = [self exportedFilePath];
    [self removeFileAtPath:exportPath];
    self.moment.mp4file.sourceUrl = [NSURL fileURLWithPath:exportPath];
    self.asset = nil;
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    session.videoComposition = videoComposition;
    session.outputURL = self.moment.mp4file.sourceUrl;
    session.outputFileType = AVFileTypeMPEG4;
    session.shouldOptimizeForNetworkUse = YES;
    self.session = session;
    [self startExporting];
}

- (void)prepareMp4file:(MP4File *)mp4file withAsset:(AVURLAsset *)asset{
    mp4file.duration = (long long)((double)asset.duration.value / (double)asset.duration.timescale*1000);
    mp4file.resolution = [self resolutionOfAsset:asset];
    NSLog(@"MP4: Duration = %@ms", @(mp4file.duration));
}

- (void) startUploading {
    // prepare parameters
    [self prepareMp4file:self.moment.mp4file withAsset:self.asset];
    // upload
    [self.cfs uploadMP4Moment:self.moment progress:self.progressBlock completion:^(BOOL done, NSError *err, NSDictionary *msg) {
        NSLog(@"MP4: Upload mp4 %@ %@", @(done), err);

        if (self.completionBlock != nil) {
            self.completionBlock(done, err, msg);
        }

        if(self.converted) {
            [self removeFileAtPath:[self filePathOfURL:self.moment.mp4file.sourceUrl]];
        }
        [self clear];
    }];
}

- (void) clear {
    self.moment = nil;
    self.session = nil;
    self.progressBlock = nil;
    self.completionBlock = nil;
}

- (void)cancel {
    [self.cfs stop];
}

- (int) resolutionOfAsset:(AVURLAsset*)asset {
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = tracks[0];
    CGSize size = track.naturalSize;
    NSLog(@"MP4: Video size %@", NSStringFromCGSize(size));
    return [VideoResolutionUtil resolutionTypeForHeight:size.height width:size.width];
}

- (NSString*) filePathOfURL:(NSURL*)url {
    NSString *path = url.absoluteString;
    if([path hasPrefix:@"file://"]) {
        path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }
    return path;
}

- (void) removeFileAtPath:(NSString*)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path]) {
        NSError *error;
        [fm removeItemAtPath:path error:&error];
        NSLog(@"MP4: remove Item : %@", error);
    }
}

- (NSInteger) rotationDegreeOfVideo:(AVAsset*)asset {
    NSUInteger degree = 0;
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    CGAffineTransform t = track.preferredTransform;
    if(t.a == 0 && t.b == 1.0) {
        degree = 90;
    } else if(t.a == 0 && t.b == -1.0) {
        degree = 270;
    } else if(t.a == 1 && t.b == 0) {
        degree = 0;
    } else if(t.a == -1 && t.b == 0){
        degree = 180;
    }
    return degree;
}

- (CGAffineTransform) transformOfVideo:(AVAsset*)asset {
    CGAffineTransform transform = CGAffineTransformIdentity;
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    NSInteger degree = [self rotationDegreeOfVideo:asset];
    if(degree == 90) {
        transform = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    } else if(degree == 180) {
        transform = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    } else if(degree == 270) {
        transform = CGAffineTransformMakeTranslation(0, videoTrack.naturalSize.width);
        transform = CGAffineTransformRotate(transform, M_PI_2*3);
    }
    return transform;
}

@end
