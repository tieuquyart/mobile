//
//  TSClient.h
//  Hachi
//
//  Created by gliu on 16/3/24.
//  Copyright © 2016年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

#if 1
#define UseGCDASyncSocket
#else
#define UseASyncSocket
#endif

@protocol WLSocketClientConnectionDelegate;

@interface WLSocketClient: NSObject
@property (strong, nonatomic, nonnull) NSMutableData *receivingBuffer;
@property (weak, nonatomic, nullable) id<WLSocketClientConnectionDelegate> connectionDelegate;
@property (assign, nonatomic) int heartBeatInterval; //=< 0: No heat beat
@property (assign, nonatomic) BOOL enableReadTimeout;

- (nonnull instancetype)initWithIPv4:(nullable NSString *)ipv4 IPv6:(nullable NSString *)ipv6 port:(long)port;

- (BOOL)connect;
- (void)disconnect;

- (nullable NSString *)getIP;
- (nullable NSString *)getIPv4;
- (nonnull NSString *)getLivePreviewAddress;

- (void)sendData:(nonnull NSData *)data withTimeout:(double)sec;

- (BOOL)isConnected;

- (void)sendHeartBeat;

//for override
- (void)onReciveBuffer:(nonnull NSData *)data;
- (void)onConnected;

@end

@protocol WLSocketClientConnectionDelegate
- (void)socketClientDidConnect:(nonnull WLSocketClient *)client;
- (void)socketClient:(nonnull WLSocketClient *)client didDisconnectWithError:(nullable NSError *)err;
@end
