//
//  CFSClient.m
//  Hachi
//
//  Created by Waylens Administrator on 8/19/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "CFSClient.h"
#import "AFNetworking.h"
#import "myGetSHA1.h"
#import "NSDate+Format.h"
#import "NSData+MD5.h"
#import "NSString+HMAC.h"
//#import "comm_protocol.h"
#import "PDRUploadMp4Moment.h"



#define WholeBufferSize (2 * 1024 * 1024)
#define BufferedStreamBufferSize 4096

typedef void (^AFURLSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);

@interface CFSClient ()<NSURLSessionDataDelegate, NSURLSessionTaskDelegate> {
    char pCurSha[32];
}

@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, copy) AFURLSessionTaskCompletionHandler completionHandler;

@property (strong, nonatomic) NSString *jid;
@property (strong, nonatomic) NSString *host;
@property (assign, nonatomic) NSUInteger port;
@property (strong, nonatomic) NSString *privateKey;
@property (assign, nonatomic) NSUInteger momentID;
//@property (strong, nonatomic) AFHTTPRequestOperation *upStreamOp;
@property (strong, nonatomic) NSURLSessionTask *uploadTask;
//@property (strong, nonatomic) NSURLSessionTask *downloadTask;
@property (strong, nonatomic) AFHTTPRequestSerializer *serializer;
@property (strong, nonatomic) AFJSONResponseSerializer *responseSerializer;
@property (nonatomic, strong) NSOutputStream * outputStream;
@property (nonatomic, strong) NSInputStream * inputStream;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, assign) BOOL uploading;
@property (nonatomic, copy) ProcessBlock progressBlock;
@property (nonatomic, assign) NSUInteger lastPercent;
@property (nonatomic, assign) long lastSentBytes;
@property (nonatomic, assign) double lastTime;
@end

@implementation CFSClient

- (instancetype)initWithBaseUrl:(NSString *)baseUrl privateKey:(NSString *)privateKey userId:(NSString *)userId {
    self = [super init];
    if (self) {
        NSURL *url = [NSURL URLWithString:baseUrl];
        _host = url.host;
        _port = url.port.unsignedIntegerValue;
        _privateKey = privateKey;
        _jid = [NSString stringWithFormat:@"%@/ios", userId];
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
        
        self.mutableData = [NSMutableData data];
        self.progress = [NSProgress progressWithTotalUnitCount:0];
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host port:(NSUInteger)port privateKey:(NSString *)privateKey userId:(NSString *)userId {
    self = [super init];
    if (self) {
        _host = host;
        _port = port;
        _privateKey = privateKey;
        _jid = [NSString stringWithFormat:@"%@/ios", userId];
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
        
        self.mutableData = [NSMutableData data];
        self.progress = [NSProgress progressWithTotalUnitCount:0];
    }
    return self;
}

-(AFHTTPRequestSerializer *)serializer {
    if (!_serializer) {
        _serializer = [AFHTTPRequestSerializer serializer];
        _serializer.HTTPMethodsEncodingParametersInURI = [_serializer.HTTPMethodsEncodingParametersInURI setByAddingObject:@"PUT"];
    }
    return _serializer;
}

-(AFJSONResponseSerializer *)responseSerializer{
    if (!_responseSerializer) {
        _responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _responseSerializer;
}

-(BOOL)isUploading {
    return _uploading;
}

-(void)stop {
    _uploading = NO;
    if (self.uploadTask.state == NSURLSessionTaskStateRunning) {
        [self.uploadTask cancel];
    }
    [self.session invalidateAndCancel];
}

-(void)notifyProgressWithSentBytes:(long)sent totalBytes:(long)total {
    if (sent<_lastSentBytes) { // another upload task
        _lastTime = 0;
        _lastPercent = 0;
        _lastSentBytes = 0;
    }
    float percent = 100 * (float)sent / (float)total;
    if (_lastTime==0) {
        _lastTime = [[NSDate date] timeIntervalSince1970];
        _lastSentBytes = sent;
        _lastPercent = percent;
        return;
    }
    double now = [[NSDate date] timeIntervalSince1970];
    if (now - _lastTime > 0.2) {
        double speed = (double)(sent - _lastSentBytes)/(now - _lastTime);
        NSDictionary *msg = @{
                              @"bps": @(speed),
                              @"total": @(total),
                              @"send": @(sent)
                              };
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressBlock(NO, nil, msg, percent);
        });
        _lastTime = now;
        _lastSentBytes = sent;
        _lastPercent = percent;
    }
}

- (NSString *)authWithString:(NSString*)toCheckSum type:(NSString *)type date:(NSString *)dateString {
    NSMutableData *converted = [[NSMutableData alloc] init];
    for (int i=0; i< toCheckSum.length; i++) {
        char c = [toCheckSum characterAtIndex:i] * 7 % 256;
        [converted appendBytes:&c length:1];
    }
    NSString *checkSum = [converted md5ASCIIEncrypt];
    NSString *stringToSign = [NSString stringWithFormat:@"WAYLENS-HMAC-SHA256&waylens_cfs&%@&%@", type, checkSum];
    NSString *signingKey = [NSString hmac:[NSString stringWithFormat:@"waylens_cfs&%@", dateString] withKey:self.privateKey];
    NSString *signature = [NSString hmac:stringToSign withKey:signingKey];
    NSString *authString = [NSString stringWithFormat:@"WAYLENS-HMAC-SHA256 %@", signature];
    return authString;
}

-(NSMutableURLRequest *)commonRequest:(NSString *)apiType parameters:(NSDictionary *)parameters key:(id)key{
    NSString *urlString = [NSString stringWithFormat:@"https://%@:%lu/%@/%@/%@", self.host, (unsigned long)self.port, CFS_API_VERSION, apiType, self.jid];
    NSError *error;
    NSMutableURLRequest *request = [self.serializer requestWithMethod:@"PUT" URLString:urlString parameters:parameters error:&error];
    NSString *date = [NSDate currentGMTDateString];
    [request setValue:date forHTTPHeaderField:@"Date"];
    
    NSString *toCheckSum = [NSString stringWithFormat:@"%@:%lu%@%@%@", _host, (unsigned long)_port, _jid, key, date];

    if([apiType isEqualToString:CFS_UPLOAD_PICTURE]) {
        toCheckSum = [NSString stringWithFormat:@"%@:%lu%@%@%@%@", _host, (unsigned long)_port, _jid, parameters[@"moment_id"], key, date];
    } else if([apiType isEqualToString:CFS_UPLOAD_RESOURCE]){
        toCheckSum = [NSString stringWithFormat:@"%@:%lu%@%@%@%@", _host, (unsigned long)_port, _jid, parameters[@"moment_id"], key, date];
    } else {
        toCheckSum = [NSString stringWithFormat:@"%@:%lu%@%@%@", _host, (unsigned long)_port, _jid, key, date];
    }
//    NSString *auth = [self authorizationStringWithKey:key type:apiType date:date];
    NSString *auth = [self authWithString:toCheckSum type:apiType date:date];
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    return request;
}

-(NSURLSessionTask *)taskWithRequest:(NSMutableURLRequest *)request completion:(FinishBlock)completion{
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request];
    self.completionHandler = ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completion) {
            if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
                completion(NO, error, responseObject);
            } else if ([responseObject[@"result"] intValue]<0){
                NSLog(@"Error: %@", responseObject);
                completion(NO, nil, responseObject);
            } else {
                completion(YES, nil, responseObject);
            }
        }
    };
    
    [task resume];
    return task;
}

-(NSURLSessionTask *)uploadTaskWithRequest:(NSMutableURLRequest *)request fromFile:(nonnull NSURL *)fileURL completion:(FinishBlock)completion{
    NSURLSessionTask *task = [self.session uploadTaskWithRequest:request fromFile:fileURL];
    self.completionHandler = ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completion) {
            if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
                completion(NO, error, responseObject);
            } else if ([responseObject[@"result"] intValue]<0){
                NSLog(@"Error: %@", responseObject);
                completion(NO, nil, responseObject);
            } else {
                completion(YES, nil, responseObject);
            }
        }
    };

    [task resume];
    return task;
}

-(void)putVideoWithParameters:(NSDictionary *)parameters momentId:(NSNumber *)key toJSON:(NSDictionary *)toJSON completion:(FinishBlock)completion {
    NSMutableURLRequest *request = [self commonRequest:CFS_UPLOAD_VIDEO parameters:parameters key:key];
    if (toJSON) {
        NSError *error;
        NSData *body = [NSJSONSerialization dataWithJSONObject:toJSON options:0 error:&error];
        NSString *jsonStr = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        NSLog(@"json body:%@", jsonStr);
        if (error) {
            completion(NO, error, @{@"code":@(-2), @"msg":@"Wrong parameters"});
            return;
        }
        [request setHTTPBody:body];
    }
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
//    [self requestOperationWithRequest:request completion:completion];
    [self taskWithRequest:request completion:completion];
}

-(void)uploadAvatar:(NSData *)data progress:(ProcessBlock)progressBlock completion:(FinishBlock)completion {
    memset(pCurSha, 0, 32);
    NSString* sha1 = [myGetSHA1 getSHA1ValueFromData:data ToBuffer:pCurSha];
    NSDictionary *parameters = @{@"file_sha1": sha1};
    NSMutableURLRequest *request = [self commonRequest:CFS_UPLOAD_AVATAR parameters:parameters key:sha1];
    [request setHTTPBody:data];
    [request setValue:@"image/*" forHTTPHeaderField:@"Content-Type"];
//    [self requestOperationWithRequest:request completion:completion];
    self.progressBlock = progressBlock;
    self.progress.totalUnitCount = data.length;
    self.progress.completedUnitCount = 0;
    [self taskWithRequest:request completion:completion];
}

-(void)initStreams{
    NSOutputStream * os;
    NSInputStream * is;
    [NSStream getBoundStreamsWithBufferSize:BufferedStreamBufferSize inputStream:&is outputStream:&os];
    self.outputStream = os;
    self.inputStream = is;
}

- (void)uploadFileFromStream:(NSInputStream *)stream parameters:(NSDictionary *)parameters momentId:(NSNumber *)momentId completion:(FinishBlock)block{
    NSMutableURLRequest *request = [self commonRequest:CFS_UPLOAD_VIDEO parameters:parameters key:momentId];
    request.HTTPBodyStream = stream;
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
//    self.upStreamOp = [self requestOperationWithRequest:request completion:block];
    self.uploadTask = [self taskWithRequest:request completion:block];
}

- (void)uploadMP4Moment:(PDRUploadMp4Moment *)moment progress:(ProcessBlock)progressBlock completion:(FinishBlock)completion {
    if (_uploading) {
        NSLog(@"upload task unfinished");
        if (completion) {
            completion(NO, [NSError errorWithDomain:@"CFSError" code:0 userInfo:nil], @{@"msg":NSLocalizedString(@"Last upload task is running", comment: @"Last upload task is running")});
        }
    }
    _uploading = YES;
    _lastTime = 0;
    _lastPercent = 0;
    _lastSentBytes = 0;
    _progressBlock = progressBlock;
    self.progress.totalUnitCount = [moment totalSize];
    self.progress.completedUnitCount = 0;

    memset(pCurSha, 0, 32);
    NSString* sha1 = [myGetSHA1 getSHA1ValueFromData:moment.mp4file.mp4data ToBuffer:pCurSha];
    NSDictionary *parameters = @{@"moment_id":@(moment.momentID),
                                 @"access_level":moment.accessLevelString,
                                 @"file_sha1": sha1,
                                 @"resolution":@(moment.mp4file.resolution),
                                 @"duration":@(moment.mp4file.duration)};
    NSMutableURLRequest *request = [self commonRequest:CFS_UPLOAD_RESOURCE parameters:parameters key:sha1];
    [request setValue:@"chunked" forHTTPHeaderField:@"Transfer-Encoding"];
    [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [request setValue:@"video/mpeg4" forHTTPHeaderField:@"Content-Type"];
    
    self.uploadTask = [self uploadTaskWithRequest:request fromFile:moment.mp4file.sourceUrl completion:completion];
}

#pragma mark - NSURLSessionDataTaskDelegate

- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.mutableData appendData:data];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(__unused NSURLSession *)session
              task:(__unused NSURLSessionTask *)task
   didSendBodyData:(__unused int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"sent bytes %@ / %@", @(totalBytesSent), @(totalBytesExpectedToSend));
    if (self.progressBlock) {
        [self notifyProgressWithSentBytes:(long)self.progress.completedUnitCount + (long)totalBytesSent totalBytes:(long)self.progress.totalUnitCount];
    }
}

- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    __block id responseObject = nil;
    
    //Performance Improvement from #2672
    NSData *data = nil;
    if ([self.mutableData length] > 0) {
        data = [self.mutableData copy];
        //We no longer need the reference, so nil it out to gain back some memory.
        self.mutableData = [NSMutableData new];
    }
    
    if (error) {
        if (data) {
            NSError *serializationError = nil;
            responseObject = [self.responseSerializer responseObjectForResponse:task.response data:data error:&serializationError];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response, responseObject, error);
            }
        });
    } else {
        NSError *serializationError = nil;
        responseObject = [self.responseSerializer responseObjectForResponse:task.response data:data error:&serializationError];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response, responseObject, serializationError);
            }
        });
    }
}

@end
