//
//  SRSUploader.m
//  Hachi
//
//  Created by gliu on 15/8/24.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import "SRSUploader.h"

#import "CRSClinet.h"
#import "NSString+MD5.h"
#import "NSData+AES.h"

#import "ALAssetsLibrary+Custom.h"

#import "myGetSHA1.h"

#include "comm_protocol.h"
#include "comm_types.h"
#include "crs_protocol.h"

@interface SRSUploader () {
    NSString*       pUserID;
    NSString*       pContentID;
    NSString*       pIP;
    long            mPort;
    NSString*       pKey;
    enum OTHER_DATA_TYPE mContentType;
    
    //private use
    NSMutableData*  _pRecvBuffer;
    int64_t         pOffset;
    
    NSData*         pToDOData;
    NSString*       pFilePath;
    ALAssetsLibrary* pLibrary;
    ALAssetRepresentation* pAssetRepresentation;
    char            pCurSha[32];
}
@end

@implementation SRSUploader

- (instancetype)initWithServerIP:(NSString*)ip port:(long)port privateKey:(NSString*)key {
    self = [super init];
    if (self) {
        pIP = [NSString stringWithString:ip];
        mPort = port;
        pKey = [NSString stringWithString:key];
        
        pToDOData = nil;
        pFilePath = nil;
        pOffset = 0;
    }
    return self;
}
- (BOOL)uploadData:(NSData*)data withType:(int)type ContentToken:(NSString*)token withBlock:(CRSProcessBlock)block {
    pContentID = [NSString stringWithString:token];
    pToDOData = data;
    
    
    return YES;
}
@end
