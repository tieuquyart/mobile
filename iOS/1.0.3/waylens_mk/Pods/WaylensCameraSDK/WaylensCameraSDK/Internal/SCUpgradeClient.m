//
//  SCUpgradeClient.m
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/30.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import "SCUpgradeClient.h"
#import "WLCameraDevice+FrameworkInternal.h"

@implementation SCUpgradeClient
- (id)initWithCamera:(WLCameraDevice*)camera {
    if (camera == nil){
        return nil;
    }
    self = [super init];
    if (self) {
        _pdevice = camera;
        _pCurrentFwVersion = @"";
        _pHwVersion = @"";
        _pCameraID = @"";
        _cliDele = nil;
        bUpgrading = NO;
        pFileHandle = nil;
        sn = [NSString stringWithString:camera.sn];
    }
    return self;
}
- (void)updateInfo {
    _pCurrentFwVersion = _pdevice.firmwareVersion;
    _pCameraID = _pdevice.sn;
    _pHwVersion = _pdevice.hardwareModel;
}

- (void)updateCamera:(WLCameraDevice*)camera {
    _pdevice = camera;
}
- (WLCameraDevice*)getDevice {
    return _pdevice;
}
- (void)sendFWtoCamera:(NSString*)file md5:(NSString*)md5 {
    localfile = file;
    if (_pdevice != nil){
        [_pdevice setFirmwareUpgradeDelegate:self];
        [_pdevice newFirmwareWithMD5:md5];
    }
}
- (BOOL)isUpgrading {
    return bUpgrading;
}
- (void)done:(BOOL)done {
    if (done){
        [_pdevice upgradeFirmware];
    }
}
- (void)startDoUpgrade {
    if (bUpgrading){
        return;
    }
    bUpgrading = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:localfile]){
        pFileHandle = [NSFileHandle fileHandleForReadingAtPath:localfile];
        offset = 0;
        filesize = [pFileHandle seekToEndOfFile];
        [pFileHandle seekToFileOffset:0];
    }
    //CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)[_pdevice getIP], 10097, Nil, &writeStream);
    //inputStream = (__bridge  NSInputStream *)readStream;
    outputStream = (__bridge   NSOutputStream *)writeStream;
    //[inputStream setDelegate:self];
    [outputStream setDelegate:self];
    //[inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    //[inputStream open];
    [outputStream open];
}

- (void)cancel {
    if (bUpgrading && [outputStream streamStatus]!=NSStreamStatusClosed){
        [outputStream close];
        outputStream = nil;
        [pFileHandle closeFile];
        pFileHandle = nil;
        bUpgrading = NO;
    }
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    //NSLog(@"stream event %d", (int)streamEvent);
    //NSLog(@"%@",theStream);
    static unsigned long long showOffsetforDebug = 0;
    switch (streamEvent){
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream){
                uint8_t buffer[1024];
                int len;
                while ([inputStream hasBytesAvailable]){
                    len = (int)[inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0){
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        if (nil != output){
                            NSLog(@"SCUpgradeClient get: %@", output);
                            //todo
                        }
                    }
                }
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            if (theStream == outputStream) {
                size_t bufsize = 1024 * 128;
                uint8_t buffer[bufsize];
                int len;
                while ([outputStream hasSpaceAvailable])
                {
                    if (offset >= filesize) {
                        [pFileHandle closeFile];
                        pFileHandle = nil;
                        [outputStream close];
                        outputStream = nil;
                        showOffsetforDebug = 0;
                        break;
                    }
                    [pFileHandle seekToFileOffset:offset];
                    NSData *data = [pFileHandle readDataOfLength:bufsize];
                    if (data){
                        [data getBytes:buffer length:[data length]];
                    }
                    len = (int)[outputStream write:buffer maxLength:[data length]];
                    if (len <= 0){
                        [pFileHandle closeFile];
                        pFileHandle = nil;
                        [outputStream close];
                        outputStream = nil;
                        showOffsetforDebug = 0;
                        NSLog(@"write outputStream error");
                        break;
                    } else {
                        offset += len;
                        [_cliDele Upgradeprocess:(int)offset/(filesize/100) Camera:self];
                    }
                }
                if (showOffsetforDebug + 1024 * 1024 < offset) {
                    NSLog(@"Send : %llu Bytes", offset);
                    showOffsetforDebug += 1024 * 1024;
                }
            }
            break;
        default:
            if (streamEvent == NSStreamEventErrorOccurred) {
                NSLog(@"Can not connect to the host!");
            } else if (streamEvent == NSStreamEventEndEncountered){
                NSLog(@"NSStreamEventEndEncountered %lu!", (unsigned long)[theStream streamStatus]);
            } else {
                NSLog(@"Unknown event");
            }
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            [_cliDele UpgradeFailedforCamera:self];
            showOffsetforDebug = 0;
            bUpgrading = NO;
            break;
    }
}

#pragma mark -- CameraDeviceUpgradeDelegate
- (void)onReadyToUpgrade {
    NSLog(@"Camera is ready to upgrade!");
    if (_cliDele){
        [_cliDele RdyToUpgradeforCamera:self];
    }
}
- (void)onUpgradeResult:(int)process {
    NSLog(@"Camera upgrade return %d!", process);
    if (_cliDele){
        if (process == 100){
            [_cliDele UpgradeDoneforCamera:self];
            [self done:YES];
        }
        if (process == -1){
            [_cliDele UpgradeFailedforCamera:self];
            bUpgrading = NO;
        }
    }
}

- (void)onTransferFirmware:(int)state size:(int)firmwareSize progress:(int)progress errorCode:(int)errorCode {

}

@end
