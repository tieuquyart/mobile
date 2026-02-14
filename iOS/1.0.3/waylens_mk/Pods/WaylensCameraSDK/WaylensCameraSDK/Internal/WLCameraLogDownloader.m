//
//  WLCameraLogDownloader.m
//  Acht
//
//  Created by gliu on 10/31/17.
//  Copyright © 2017 waylens. All rights reserved.
//

#import "WLCameraLogDownloader.h"

#import "GCDAsyncSocket.h"

#import <sys/socket.h>

@interface WLCameraLogDownloader () {
    GCDAsyncSocket *pAsyncSocket;
    NSString*   pIP;
    long        mPort;
    NSInteger _dataLength;
}
@property (nonatomic, strong) NSMutableData *receiveBuffer;
@property (assign, nonatomic, readonly) NSInteger dataLength;
@end

@implementation WLCameraLogDownloader

-(NSInteger)dataLength {
    return _dataLength;
}

- (instancetype)initWithIP:(NSString*)ip port:(long)port {
    self = [super init];
    if (self) {
        pIP = [NSString stringWithString:ip];
        mPort = port;
        NSLog(@"%@ initWithIP:%@:%ld", NSStringFromClass([self class]), ip, port);
        pAsyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)downloadToFile:(NSURL *)file {
    if (file.path != _fileUrl.path) {
        [self cleanUpFile];
    }

    self.fileUrl = file;

    [self cleanUpFile];
    [self connect];
}

-(void)cancel {
    [self disconnect];
}

- (void)cleanUpFile {
    if (_fileUrl != nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:_fileUrl.path]) {
            [[NSFileManager defaultManager] removeItemAtURL:_fileUrl error:nil];
        }
    }
}

- (BOOL)connect {
    NSError *error = nil;
    NSLog(@"%@ connect: %@:%ld...", NSStringFromClass([self class]), pIP, mPort);
    _receiveBuffer = [NSMutableData data];
    _dataLength = -1;
    BOOL ret = [pAsyncSocket connectToHost:pIP onPort:mPort withTimeout:5 error:&error];
    if (!ret) {
        NSLog(@"%@ connection error: %@", NSStringFromClass([self class]), error);
        [self.delegate cameraLogDownloader:self downloadFinished:NO error:error];
    }
    return ret;
}

- (void)disconnect {
    if ([pAsyncSocket isConnected]) {
        [pAsyncSocket disconnect];
    }
}

- (void)onReciveBuffer:(nonnull NSData *)data {
    [self.receiveBuffer appendData:data];
    float progress = (float)self.receiveBuffer.length / (float)_dataLength;
    [self.delegate cameraLogDownloader:self downloadProgressDidChange:progress];
    if (self.receiveBuffer.length == _dataLength) {
        BOOL ret = [self.receiveBuffer writeToURL:self.fileUrl atomically:true];
        [self.delegate cameraLogDownloader:self downloadFinished:ret error:nil];
        [self disconnect];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"%@ didConnectToHost", NSStringFromClass([self class]));
    //    [self onConnected];
    [pAsyncSocket readDataToLength:4 withTimeout:-1 tag:0];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"%@ socketDidDisconnect:%@:%ld withError: %@", NSStringFromClass([self class]), pIP, mPort, err);
    if (err.code == 7) {
        // socket closed by remote peer
    } else {
        [self.delegate cameraLogDownloader:self downloadFinished:NO error:err];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (![pAsyncSocket isEqual:sock]) {
        return;
    }
    if (_dataLength < 0) {
        NSData *data4 = [data subdataWithRange:NSMakeRange(0, 4)];
        int32_t value;
        [data4 getBytes:&value length:4];
        if (value <= 0) {
            [self.delegate cameraLogDownloader:self downloadFinished:NO error:nil];
            [self disconnect];
            return;
        }
        _dataLength = value;
        if (data.length > 4) {
            [self onReciveBuffer: [data subdataWithRange:NSMakeRange(4, data.length - 4)]];
        }
    } else {
        [self onReciveBuffer:data];
    }
    [pAsyncSocket readDataWithTimeout:-1 tag:0];
}

@end

