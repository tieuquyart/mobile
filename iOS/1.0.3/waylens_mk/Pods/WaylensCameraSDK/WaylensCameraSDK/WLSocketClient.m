//
//  TSClient.m
//  Hachi
//
//  Created by gliu on 16/3/24.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import "WLSocketClient.h"

#ifdef UseGCDASyncSocket
#import "GCDAsyncSocket.h"
#else
#import "AsyncSocket.h"
#endif

#import <sys/socket.h>

@interface WLSocketClient () <
#ifdef UseGCDASyncSocket
GCDAsyncSocketDelegate
#else
#endif
> {
#ifdef UseGCDASyncSocket
    GCDAsyncSocket *pAsyncSocket;
#else
    AsyncSocket *pAsyncSocket;
#endif
    NSString*   pIPv4;
    NSString*   pIPv6;
    long        mPort;
    BOOL        tryIPv6;
    BOOL        needtryIPv6;

    int         reConnectTimes;

    NSTimer*    reconnectTimer;
    NSTimer*    heatBeatTimer;
    int         timeOutOfHeatBeatTimes;
}

@end

@implementation WLSocketClient

- (nonnull instancetype)initWithIPv4:(nullable NSString *)ipv4 IPv6:(nullable NSString *)ipv6 port:(long)port {
    self = [super init];
    if (self) {
        pIPv4 = ipv4 ? [NSString stringWithString:ipv4] : nil;
        pIPv6 = ipv6 ? [NSString stringWithString:ipv6] : nil;
        mPort = port;
        reConnectTimes = 0;
        reconnectTimer = nil;
        _heartBeatInterval = 0;
        timeOutOfHeatBeatTimes = 3;
//        if ([carrier containsString:@"T-Mobile"] || [carrier containsString:@"Rogers"]) {
//            tryIPv6 = YES;
//            needtryIPv6 = YES;
//        } else {
//            tryIPv6 = YES;
//            needtryIPv6 = YES;
//        }
        tryIPv6 = pIPv6 ? YES : NO;
        needtryIPv6 = pIPv6 ? YES : NO;;
        NSLog(@"%@ initWithIPv4:%@, IPv6:%@, port:%ld", NSStringFromClass([self class]), ipv4, ipv6, port);
#ifdef UseGCDASyncSocket
        __weak typeof(self) weakself = self;
        pAsyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:weakself delegateQueue:dispatch_get_main_queue()];
#else
        pAsyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
#endif
        _receivingBuffer = [[NSMutableData alloc] init];
        _enableReadTimeout = YES;
    }
    return self;
}

- (BOOL)connect {
    NSError *error = nil;
    NSLog(@"%@ connect: %@:%ld...", NSStringFromClass([self class]), [self getIP], mPort);
    BOOL ret = [pAsyncSocket connectToHost:[self getIP]
                                    onPort:mPort
//                              viaInterface:@"en0"
                               withTimeout:5
                                     error:&error];
    if (!ret) {
        NSLog(@"CameraClient Error connecting: %@", error);
    }
    if (reconnectTimer) {
        [reconnectTimer invalidate];
        reconnectTimer = nil;
    }
    return ret;
}

- (void)disconnect {
    if (reconnectTimer) {
        [reconnectTimer invalidate];
        reconnectTimer = nil;
    }
//    if ([pAsyncSocket isConnected]) {
        [pAsyncSocket disconnect];
//    }
}

- (nullable NSString *)getIP {
    if (tryIPv6) {
        return pIPv6;
    }
    return pIPv4;
}

- (nullable NSString *)getIPv4 {
    return pIPv4;
}

- (nonnull NSString *)getLivePreviewAddress {
    if (tryIPv6) {
        return [NSString stringWithFormat:@"http://[%@]:%d/?fps=10", pIPv6, 8081];
    }
    return [NSString stringWithFormat:@"http://%@:%d/?fps=10", pIPv4, 8081];
}

- (void)onReciveBuffer:(nonnull NSData *)data {
}
- (void)onConnected {
    [_connectionDelegate socketClientDidConnect:self];
}

- (BOOL)isConnected {
    return [pAsyncSocket isConnected];
}
- (void)sendHeartBeat {
    char i[0];
    i[0] = '\n';
    [self sendData:[NSData dataWithBytes:i length:1] withTimeout:3];
}
- (void)sendData:(nonnull NSData *)data withTimeout:(double)sec {
    [pAsyncSocket writeData:data withTimeout:sec tag:0];
}
- (void) tryConnect {
    if ((pIPv6 != nil) && needtryIPv6 && (!tryIPv6)) {
        tryIPv6 = YES;
    } else {
        tryIPv6 = NO;
    }
    NSLog(@"%@ tryConnect (%@)!", NSStringFromClass([self class]), [self getIP]);
    [self connect];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef UseGCDASyncSocket
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
#else
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
#endif
{
    NSLog(@"%@ didConnectToHost", NSStringFromClass([self class]));
    reConnectTimes = 0;
    [self onConnected];
    [pAsyncSocket readDataWithTimeout:_heartBeatInterval > 0 ? _heartBeatInterval * timeOutOfHeatBeatTimes : -1 tag:0];
    if (_heartBeatInterval > 0) {
        if (heatBeatTimer) {
            [heatBeatTimer invalidate];
            heatBeatTimer = nil;
        }
        heatBeatTimer = [NSTimer timerWithTimeInterval:_heartBeatInterval target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:heatBeatTimer forMode:NSRunLoopCommonModes];
    }
}
#ifdef UseGCDASyncSocket
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
#else
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
#endif
{
    if (heatBeatTimer) {
        [heatBeatTimer invalidate];
        heatBeatTimer = nil;
    }
    if (reconnectTimer) {
        [reconnectTimer invalidate];
        reconnectTimer = nil;
    }
    reConnectTimes += 1;
    NSLog(@"%@ socketDidDisconnect:%@:%ld withError: %@", NSStringFromClass([self class]), [self getIP], mPort, err);
    if (reConnectTimes < 5) {
        reconnectTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(tryConnect) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:reconnectTimer forMode:NSRunLoopCommonModes];
    } else {
        [_connectionDelegate socketClient:self didDisconnectWithError:err];
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    if (self.enableReadTimeout) {
        return 0;
    } else {
        return _heartBeatInterval * timeOutOfHeatBeatTimes;
    }
}

#ifdef UseGCDASyncSocket
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
#else
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
#endif
{
    //NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

#ifdef UseGCDASyncSocket
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
#else
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
#endif
{
//    NSLog(@"%@ didReadData:withTag:%ld, len %d", NSStringFromClass([self class]), tag, (int)data.length);
    if ([pAsyncSocket isEqual:sock]) {
        [self onReciveBuffer:data];
    }
    [pAsyncSocket readDataWithTimeout:_heartBeatInterval > 0 ? _heartBeatInterval * timeOutOfHeatBeatTimes : -1 tag:0];
}

@end
