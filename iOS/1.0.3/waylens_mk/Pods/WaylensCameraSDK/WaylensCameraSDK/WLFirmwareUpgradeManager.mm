//
//  WLFirmwareUpgradeManager.m
//  Vidit
//
//  Created by gliu on 14-9-16.
//  Copyright (c)2014年 Transee Design. All rights reserved.
//

#import "WLFirmwareUpgradeManager.h"
#import "WLBonjourCameraListManager.h"
#import "Reachability.h"
#import <WaylensFoundation/WaylensFoundation.h>
#import <WaylensCameraSDK/WaylensCameraSDK-Swift.h>
#import "WLFirmwareUpgradeManager+FrameworkInternal.h"
#import "WLCameraDevice+FrameworkInternal.h"
#import "SCUpgradeClient.h"

#define FWInfoConfig        @"/FwInfoConfig.xml"

//json element
#define DEVICE_FWUPDATE_DEVICE_MODEL    "name"
#define DEVICE_FWUPDATE_BSP_VERSION     "BSPVersion"
#define DEVICE_FWUPDATE_API_VERSION     "version"
#define DEVICE_FWUPDATE_URL             "url"
#define DEVICE_FWUPDATE_SIZE            "size"
#define DEVICE_FWUPDATE_DSCRPT          "description"
#define DEVICE_fWUPDATE_MD5             "md5"

#define DEVICE_fWUPDATE_ISFROMEXTERNAL  "external"
#define DEVICE_fWUPDATE_DOWNLOADDATE    "downloadDate"

#define HARDWARE_EXTERNAL   "external"

typedef void(^UpgradeBlock)(void);

@interface WLFirmwareInfo ()

@property (strong, nonatomic) id<FwInforDelegate> delegate;

@end

@implementation WLFirmwareInfo {
    NSString*   pHwVersion;
    NSString*   pLatestBSPVersion;
    NSString*   pLatestAPIVersion;
    NSString*   md5;
    long        fwSize;
    NSString*   pUrl;
    WLFirmwareStatus    status;
    NSString*   plocalFile;
    NSString*   plocalFileName;
    NSDictionary*   pDescriptions;
    
    NSURLConnection*    pConnection;
    long long           expectedBytes;
    long long           rcvedBytes;
    NSFileHandle        *pFileHandler;
    UpgradeBlock        checkOKblock;
    UpgradeBlock        checkFailedblock;
    
    BOOL    bDownloadPaused;
    
    BOOL    bFromExternal;
    double  downloadDate;
}

- (id)init {
    self = [super init];
    if (self){
        [self myInit];
    }
    return self;
}
- (id)initWithHw:(NSString*)hw Fw:(NSString*)fw Url:(NSString*)url {
    self = [super init];
    if (self){
        [self myInit];
        pHwVersion = hw;
        pLatestBSPVersion = fw;
        pUrl = url;
    }
    return self;
}
- (void)myInit {
    pHwVersion = @"";
    pLatestBSPVersion = @"";
    pLatestAPIVersion = @"";
    status = WLFirmwareStatusIdle;
    plocalFile = @"";
    plocalFileName = @"";
    pUrl = @"";
    pDescriptions = [[NSDictionary alloc] init];
    
    pConnection = nil;
    rcvedBytes = 0;
    expectedBytes = 0;
    _delegate = nil;
    
    bDownloadPaused = NO;
    bFromExternal = NO;
    downloadDate = 0;
}
- (id)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self){
        [self myInit];
        if ([dict objectForKey:@DEVICE_FWUPDATE_DEVICE_MODEL] != Nil){
            pHwVersion = [dict objectForKey:@DEVICE_FWUPDATE_DEVICE_MODEL];
        }else{
            pHwVersion = @"";
        }
        if ([dict objectForKey:@DEVICE_FWUPDATE_BSP_VERSION] != Nil){
            pLatestBSPVersion = [dict objectForKey:@DEVICE_FWUPDATE_BSP_VERSION];
        }else{
            pLatestBSPVersion = @"";
        }
        if ([dict objectForKey:@DEVICE_FWUPDATE_API_VERSION] != Nil){
            pLatestAPIVersion = [dict objectForKey:@DEVICE_FWUPDATE_API_VERSION];
        }else{
            pLatestAPIVersion = @"";
        }
        if ([dict objectForKey:@DEVICE_FWUPDATE_URL] != Nil){
            pUrl = [dict objectForKey:@DEVICE_FWUPDATE_URL];
        }else{
            pUrl = @"";
        }
        if ([dict objectForKey:@DEVICE_FWUPDATE_SIZE] != Nil){
            fwSize = [[dict objectForKey:@DEVICE_FWUPDATE_SIZE] longValue];
        }else{
            fwSize = 0;
        }
        if ([dict objectForKey:@DEVICE_fWUPDATE_MD5] != Nil){
            md5 = [dict objectForKey:@DEVICE_fWUPDATE_MD5];
        }else{
            md5 = @"";
        }
        if ([dict objectForKey:@DEVICE_FWUPDATE_DSCRPT] != Nil){
            pDescriptions = [NSDictionary dictionaryWithDictionary:[dict objectForKey:@DEVICE_FWUPDATE_DSCRPT]];
        }else{
            //[pDescriptions c];
        }
        if ([dict objectForKey:@"status"] != Nil){
            status = [[dict objectForKey:@"status"] integerValue] == WLFirmwareStatusDownloaded ? WLFirmwareStatusDownloaded : WLFirmwareStatusIdle;//(FWStatus)[[dict objectForKey:@"status"] integerValue];
        } else {
            status = WLFirmwareStatusIdle;
        }
        if ([dict objectForKey:@"LocalFile"] != Nil){
            plocalFileName = [dict objectForKey:@"LocalFile"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *basePath = ([paths count] > 0)? [paths objectAtIndex:0] : nil;
            plocalFile = [basePath stringByAppendingFormat:@"/FW/%@", plocalFileName];
        }else{
            plocalFileName = @"";
            plocalFile = @"";
        }
        
        if ([dict objectForKey:@DEVICE_fWUPDATE_ISFROMEXTERNAL] != Nil){
            bFromExternal = [[dict objectForKey:@DEVICE_fWUPDATE_ISFROMEXTERNAL] boolValue];
        }
        if ([dict objectForKey:@DEVICE_fWUPDATE_DOWNLOADDATE] != Nil){
            downloadDate = [[dict objectForKey:@DEVICE_fWUPDATE_DOWNLOADDATE] doubleValue];
        }
    }
    return self;
}

- (NSDictionary*)generateDictionaryObject {
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                pHwVersion, pLatestBSPVersion, pLatestAPIVersion,
                                                pUrl, [NSNumber numberWithLongLong:fwSize],
                                                md5, pDescriptions,
                                                [NSNumber numberWithBool:bFromExternal],
                                                [NSNumber numberWithDouble:downloadDate],
                                                [NSNumber numberWithInt:status], plocalFileName, nil]
                                       forKeys:[NSArray arrayWithObjects:
                                                @DEVICE_FWUPDATE_DEVICE_MODEL, @DEVICE_FWUPDATE_BSP_VERSION, @DEVICE_FWUPDATE_API_VERSION,
                                                @DEVICE_FWUPDATE_URL, @DEVICE_FWUPDATE_SIZE,
                                                @DEVICE_fWUPDATE_MD5, @DEVICE_FWUPDATE_DSCRPT, @DEVICE_fWUPDATE_ISFROMEXTERNAL, @DEVICE_fWUPDATE_DOWNLOADDATE,
                                                @"status", @"LocalFile", nil]];
}

- (NSString*)getBSPVersion {
    return pLatestBSPVersion;
}

- (NSString*)getHardwareVersion {
    return pHwVersion;
}
- (NSDictionary*)getUpgradeDescription {
    return pDescriptions;
}

- (NSString*)getLocalizedUpgradeDescription {
    NSString* des = nil;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    for (NSString* item in pDescriptions.allKeys) {
        if ([preferredLang containsString:item]) {
            des = [NSString stringWithUTF8String:[[pDescriptions objectForKey:item] UTF8String]];
        }
    }
    if (des == nil) {
        des = [pDescriptions objectForKey:@"en"];
    }
    return des;
}

- (void)updateUpgradeDescription:(NSDictionary*)desc {
    pDescriptions = desc;
}

- (BOOL)CanUpgradeFromAppForVersion:(NSString*)fw {
    if ([pHwVersion isEqualToString:@"tw_hachi"]){
        return YES;
    }
    if ([pHwVersion isEqualToString:@"HACHI_V0C"]){
        return YES;
    }
    if ([pHwVersion isEqualToString:@"agb_diablo"]){
        const char* fwver = [fw cStringUsingEncoding:NSUTF8StringEncoding];
        char latsub[5][256];
        strcpy(latsub[0], fwver);
        char* sep = strstr(latsub[0], ".");
        if (sep == NULL){
            return NO;
        }
        strcpy(latsub[1], sep + 1);
        sep[0] = '\0';
        sep = strstr(latsub[1], ".");
        if (sep == NULL){
            return NO;
        }
        strcpy(latsub[2], sep + 1);
        sep[0] = '\0';
        sep = strstr(latsub[2], ".");
        if (sep == NULL){
            return NO;
        }
        strcpy(latsub[3], sep + 1);
        sep[0] = '\0';
        sep = strstr(latsub[3], ".");
        if (sep == NULL){
            return NO;
        }
        strcpy(latsub[4], sep + 1);
        sep[0] = '\0';
        //NSLog(@"latestFW: %s %s %s %s %s", latsub[0], latsub[1], latsub[2], latsub[3], latsub[4]);
        if (atoi(latsub[2])< 236118){
            return NO;
        }
        if (atoi(latsub[3])< 3331){
            return NO;
        }
        if (atoi(latsub[4])< 641){
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)isNotSameWith:(NSDictionary*)fw {
    if ([pLatestBSPVersion isEqualToString:[fw objectForKey:@DEVICE_FWUPDATE_BSP_VERSION]] == NO){
        return YES;
    }
    if ([pLatestAPIVersion isEqualToString:[fw objectForKey:@DEVICE_FWUPDATE_API_VERSION]] == NO){
        return YES;
    }
    if ([pUrl isEqualToString:[fw objectForKey:@DEVICE_FWUPDATE_URL]] == NO){
//        return YES;
    }
    if ([md5 isEqualToString:[fw objectForKey:@DEVICE_fWUPDATE_MD5]] == NO){
        return YES;
    }
    return NO;
}
- (NSString*)getLatestFirmwareVersion {
    return pLatestBSPVersion;
}
- (NSString*)getLatestAPIVersion {
    return pLatestAPIVersion;
}
- (BOOL)needUpgrade:(NSString*)currentFirmwareVersion {
    const char* cur = [currentFirmwareVersion cStringUsingEncoding:NSUTF8StringEncoding];
    char cursub[5][256];
    strcpy(cursub[0], cur);
    char * sep = strstr(cursub[0], ".");
    if (sep == NULL){
        return NO;
    }
    strcpy(cursub[1], sep + 1);
    sep[0] = '\0';
    sep = strstr(cursub[1], ".");
    if (sep == NULL){
        return NO;
    }
    strcpy(cursub[2], sep + 1);
    sep[0] = '\0';
    sep = strstr(cursub[2], ".");
    if (sep == NULL){
        return NO;
    }
    strcpy(cursub[3], sep + 1);
    sep[0] = '\0';
    sep = strstr(cursub[3], ".");
    if (sep == NULL){
        return NO;
    }
    strcpy(cursub[4], sep + 1);
    sep[0] = '\0';
    NSLog(@"currentFw: %s %s %s %s %s", cursub[0], cursub[1], cursub[2], cursub[3], cursub[4]);
    
    const char* latest = [pLatestBSPVersion cStringUsingEncoding:NSUTF8StringEncoding];
    char latsub[5][256];
    strcpy(latsub[0], latest);
    sep = strstr(latsub[0], ".");
    if (sep == NULL){
        return NO;
    }
    strcpy(latsub[1], sep + 1);
    sep[0] = '\0';
    sep = strstr(latsub[1], ".");
    if (sep == NULL){
        return NO;
    }
    strcpy(latsub[2], sep + 1);
    sep[0] = '\0';
    sep = strstr(latsub[2], ".");
    if (sep == NULL){
        return NO;
    }
    strcpy(latsub[3], sep + 1);
    sep[0] = '\0';
    sep = strstr(latsub[3], ".");
    if (sep == NULL){
        return NO;
    }
    strcpy(latsub[4], sep + 1);
    sep[0] = '\0';
    NSLog(@"latestFW: %s %s %s %s %s", latsub[0], latsub[1], latsub[2], latsub[3], latsub[4]);
    
    if (atoi(cursub[0]) < atoi(latsub[0])) {
        //
        return YES;
    }
    if (atoi(cursub[1]) < atoi(latsub[1])) {
        //?
        return YES;
    }
    if (atoi(cursub[2]) < atoi(latsub[2])) {
        //
        return YES;
    }
    if (atoi(cursub[3]) < atoi(latsub[3])) {
        //?
        return YES;
    }
    if (atoi(cursub[4]) < atoi(latsub[4])) {
        //?
        return YES;
    }
    
    return NO;
}
- (BOOL)isNewVersion:(NSString*)newFw {
    return NO;
}
- (int)CheckAccessable {
    if ([pUrl isEqualToString:@""]){
        return -1;
    }
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable){
        return 1;
    } else {
        return 0;
    }
}
- (void)setStatus:(WLFirmwareStatus)sta {
    status = sta;
}
- (WLFirmwareStatus)getStatus {
    return status;
}
- (void)setLocalFWFile:(NSString*)file {
    plocalFile = [NSString stringWithString:file];
}
- (NSString*)getLocalFWFile {
    return plocalFile;
}
- (NSString*)getFWmd5 {
    return md5;
}
- (void)DeleteLocalFW {
    if (pConnection) {
        [pConnection cancel];
    }
    if ([plocalFile isEqualToString:@""] == NO && [plocalFileName isEqualToString:@""] == NO){
        if ([[NSFileManager defaultManager] fileExistsAtPath:plocalFile]) {
            [[NSFileManager defaultManager]removeItemAtPath:plocalFile error:nil];
            status = WLFirmwareStatusIdle;
            NSLog(@"DeleteLocalFW %@", plocalFileName);
        }
    }
}
- (long)getFirmwareSize {
    return fwSize;
}
- (void)stopDownloading {
    if (pConnection) {
        NSLog(@"stopDownloading FW");
        [pConnection cancel];
        pConnection = nil;
        [pFileHandler closeFile];
        pFileHandler = nil;
        status = WLFirmwareStatusFailed;
    }
}
- (void)onEnterForeground {
    if (bDownloadPaused) {
        bDownloadPaused = NO;
        [self DownloadFromServer:YES];
    }
}
- (void)onEnterBackground {
    if (pConnection) {
        [self stopDownloading];
        bDownloadPaused = YES;
    }
}

- (BOOL)isFromExternal {
    return bFromExternal;
}
- (NSString*)downloadUrl {
    return pUrl;
}
- (double)downloadDate {
    return downloadDate;
}
- (void)DownloadFromServer:(BOOL)must {
    if (pConnection != nil){
        //is running
        return;
    }
    if (status == WLFirmwareStatusDownloaded){
        return;
    }
//    if (must == NO && (status == WLFirmwareStatusIdle || status == WLFirmwareStatusFailed)){
    if (must == NO){
        return;
    }
    int access = [self CheckAccessable];
    if (access == -1){
        status = WLFirmwareStatusNotFound;
        if (_delegate){
            [_delegate FwDownloadErrorforHw:pHwVersion];
        }
        return;
    }
    if (access == 0){
        if (_delegate){
            [_delegate FwServerCannotAccessforHw:pHwVersion];
        }
        status = WLFirmwareStatusDownloading;
        return;
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        NSURL *url = [NSURL URLWithString:self->pUrl];
        NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                              timeoutInterval:10];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0)? [paths objectAtIndex:0] : nil;
        
        if (WaylensCameraSDKConfig.current.target == WaylensCameraSDKTargetToC) {
            self->plocalFileName = [NSString stringWithFormat:@"%@.fw", self->pHwVersion];
        }
        else {
            self->plocalFileName = url.lastPathComponent;
        }
        
        self->plocalFile = [basePath stringByAppendingFormat:@"/FW/%@", self->plocalFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self->plocalFile] == NO) {
            [[NSFileManager defaultManager] createFileAtPath:self->plocalFile contents:nil attributes:nil];
        }
        self->pFileHandler = [NSFileHandle fileHandleForWritingAtPath:self->plocalFile];
        
        unsigned long long downloadedBytes = [self->pFileHandler seekToEndOfFile];
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
        [theRequest setValue:requestRange forHTTPHeaderField:@"Range"];
        self->rcvedBytes = downloadedBytes;
        self->pConnection = [[NSURLConnection alloc] initWithRequest:theRequest
                                                            delegate:self
                                                    startImmediately:NO];
        [self->pConnection start];
        NSLog(@"DownloadFromServer start: %@", self->pUrl);
        self->status = WLFirmwareStatusDownloading;
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        if (self->_delegate){
            self->expectedBytes = self->fwSize;
            [self->_delegate FwDownloading:(self->expectedBytes > 0) ? (int)(self->rcvedBytes*100/self->expectedBytes) : 0 downloaded:(long)self->rcvedBytes forHw:self->pHwVersion];
        }
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    expectedBytes = rcvedBytes + [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (pFileHandler == nil) {
        return;
    }
    [pFileHandler seekToEndOfFile];
    [pFileHandler writeData:data];
    rcvedBytes += [data length];
    //float progressive = (float)rcvedBytes / (float)expectedBytes;
    //NSLog(@"didReceiveData: %0.1f%%", progressive*100);
    if (_delegate){
        int process = (int)(rcvedBytes*100/expectedBytes);
        if (process == 0){
            process = 1;
        }
        [_delegate FwDownloading:process downloaded:(long)rcvedBytes forHw:pHwVersion];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [pFileHandler closeFile];
    pFileHandler = nil;
    status = WLFirmwareStatusFailed;
    NSLog(@"connection didFailWithError %@",error);
    if (_delegate){
        [_delegate FwDownloading:-1 downloaded:(long)rcvedBytes forHw:pHwVersion];
        [_delegate FwDownloadErrorforHw:pHwVersion];
        [pConnection cancel];
        pConnection = nil;
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                   willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Succeeded! Received %lld bytes of data", rcvedBytes);
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    fwSize = rcvedBytes;
    [pFileHandler closeFile];
    pFileHandler = nil;
    pConnection = nil;
    if (rcvedBytes < 50000) {
        status = WLFirmwareStatusFailed;
        [_delegate FwDownloadErrorforHw:pHwVersion];
    } else
        if (self.isFromExternal) {
            status = WLFirmwareStatusDownloaded;
            downloadDate = [[NSDate new] timeIntervalSince1970];
            NSString *smd5 = [FileUtil getfileMD5:plocalFile];
            md5 = smd5;
            [_delegate FwDownloading:200 downloaded:(long)rcvedBytes forHw:pHwVersion];
        } else {
            __weak typeof(self) weakSelf = self;
            
            [self checkFWValidWithComplete:^(){
                __strong typeof(weakSelf) strongself = weakSelf;
                
                strongself->status = WLFirmwareStatusDownloaded;
                strongself->downloadDate = [[NSDate new] timeIntervalSince1970];
                [strongself->_delegate FwDownloading:200 downloaded:(long)strongself->rcvedBytes forHw:strongself->pHwVersion];
            }
                                    failed:^(){
                __strong typeof(weakSelf) strongself = weakSelf;
                
                strongself->status = WLFirmwareStatusFailed;
                [strongself->_delegate FwDownloadErrorforHw:strongself->pHwVersion];
            }];
        }
}
- (void)checkFWValidWithComplete:(UpgradeBlock)completeblock failed:(UpgradeBlock)failedblock {
    checkOKblock = completeblock;
    checkFailedblock = failedblock;
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(doCheckFW)object:nil];
    [thread setName:@"Upgrade-doCheckFW"];
    [thread start];
}
- (void)doCheckFW {
    NSString *smd5 = [FileUtil getfileMD5:plocalFile];
    if ([md5 isEqualToString:smd5]) {
        checkOKblock();
    } else {
        NSLog(@"doCheckFW failed: %@ %@", md5, smd5);
        checkFailedblock();
        [self DeleteLocalFW];
    }
}
@end

@interface WLFirmwareUpgradeManager () <FwInforDelegate, UpgCliDelegate>
@property (strong, nonatomic) WLEvcamFirmwareUpdater *firmwareUpdater;

@property (strong, nonatomic) NSMutableArray *pFWInfos;
@property (strong, nonatomic) NSMutableArray *pClinets;
@property (strong, nonatomic) NSMutableArray *pDelegate;
@property (strong, nonatomic) WLFirmwareInfo *fwToDownload;

- (SCUpgradeClient *)clientFor:(WLCameraDevice *)camera;

@end

@implementation WLFirmwareUpgradeManager {
    NSThread *UpgradeManagerThread;
    BOOL bCheckDone;
    BOOL bChecking;
    NSLock *_lock;
    BOOL bTras2SomeCamera;
    SCUpgradeClient* pTransferClient;
}

+ (instancetype)sharedManager {
    static dispatch_once_t pred;
    static WLFirmwareUpgradeManager *pManagerInstance = nil;
    dispatch_once(&pred, ^{
        pManagerInstance = [[[self class] alloc] init];
    });
    return pManagerInstance;
}

- (id)init {
    self = [super init];
    if (self){
        bCheckDone = NO;
        bChecking = NO;
        _pFWInfos = [[NSMutableArray alloc]init];
        _pClinets = [[NSMutableArray alloc]init];
        _pDelegate = [[NSMutableArray alloc]init];
        [self LoadConfig];
        UpgradeManagerThread = [[NSThread alloc]initWithTarget:self selector:@selector(MainLoop)object:nil];
        [UpgradeManagerThread setName:@"WLFirmwareUpgradeManager"];
        [UpgradeManagerThread start];
        _lock = [[NSLock alloc]init];
        bTras2SomeCamera = NO;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}
@synthesize server = _server;
-(NSString *)server {
    if (_server == nil) {
        _server = @"https://agent.waylens.com";
    }
    return _server;
}

-(void)setServer:(NSString *)server {
    if ([server isEqual:_server]) {
        return;
    }
    _server = server;
    [self checkFromServer];
}

-(BOOL)getBetaFirmware {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"com.hachi.firmware.betaTester"] != nil) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"com.hachi.firmware.betaTester"];
    }
    return NO;
    // set this key in settings, to become a beta tester. If disable, remove this key.
}

-(WLFirmwareInfo *)firmwareInfoForModel:(NSString *)model {
    for (WLFirmwareInfo* info in _pFWInfos) {
        if ([[info getHardwareVersion] isEqualToString:[model stringByAppendingString: self.getBetaFirmware ? @"_BETA" : @""]]) {
            return info;
        }
    }
    return nil;
}

-(WLFirmwareInfo *)firmwareInfoForModel:(NSString *)model bspVersion:(NSString *)bspVersion {
    for (WLFirmwareInfo* info in _pFWInfos) {
        if ([[info getHardwareVersion] isEqualToString:model] && [[info getBSPVersion] isEqualToString:bspVersion]) {
            return info;
        }
    }
    return nil;
}

- (BOOL)checkforDevice:(WLCameraDevice*)camera {
    [_lock lock];
    BOOL result = NO;
    if ([camera.firmwareVersion isEqualToString:@"beta"]){
        [_lock unlock];
        return YES;
    }
    for (SCUpgradeClient* cam in _pClinets) {
        if (([cam getDevice].sn == camera.sn) && ([cam getDevice].hardwareModel == camera.hardwareModel)) {
            [cam updateInfo];
            for (WLFirmwareInfo* info in _pFWInfos) {
                if ([[info getHardwareVersion] isEqualToString:[cam.pHwVersion stringByAppendingString: self.getBetaFirmware ? @"_BETA" : @""]]) {
                    if (cam.pCurrentFwVersion && ![cam.pCurrentFwVersion isEqualToString:@""]) {
                        NSLog(@"%@ %@",info.getLatestFirmwareVersion, cam.pCurrentFwVersion);
                        if ([info needUpgrade:cam.pCurrentFwVersion]) {
                            result = YES;
                            if (!self.fwToDownload && [info getStatus]!=WLFirmwareStatusDownloaded && [info getStatus]!=WLFirmwareStatusDownloading) {
                                self.fwToDownload = info;
                            }
                        }
                        [camera setNeedUpgrade:result withAPIVersion:info.getLatestAPIVersion andBSPVersion:info.getLatestFirmwareVersion andDescription:[info getUpgradeDescription]];
                        break;
                    } else {
                        
                    }
                }
            }
            break;
        }
    }
    [_lock unlock];
    return result;
}

- (BOOL)canUpgradeFromAppForHardware:(NSString*)hw firmware:(NSString*)fw {
    [_lock lock];
    for (WLFirmwareInfo *infor in _pFWInfos){
        if ([[infor getHardwareVersion] isEqualToString:hw]){
            [_lock unlock];
            return [infor CanUpgradeFromAppForVersion:fw];
        }
    }
    [_lock unlock];
    return NO;
}

- (void)MainLoop {
    //CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
    //run loop
    [self CheckMain];
    //CFRunLoopRun();
}
- (void)CheckMain {
    [NSThread sleepForTimeInterval:2];
    while (1){
        if (!bCheckDone && !bChecking && [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) {
            [self doCheckFromServer];
            bChecking = YES;
        }
        if (bCheckDone) {
            [_lock lock];
            for (SCUpgradeClient* cli in _pClinets) {
                [cli updateInfo];
                if ([cli.pCurrentFwVersion isEqualToString:@""]) {
                    //                [cli getFwVersion];
                }
            }
            
            if (WaylensCameraSDKConfig.current.target == WaylensCameraSDKTargetToC) {
                for (WLFirmwareInfo* info in _pFWInfos){
                    [info DownloadFromServer:NO];
                }
            }
            
            if (bTras2SomeCamera){
                if (pTransferClient != nil){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^() {
                        [self->pTransferClient startDoUpgrade];
                    }];
                } else {
                    bTras2SomeCamera = NO;
                }
            }
            [_lock unlock];
        }
        [NSThread sleepForTimeInterval:4];
    }
}

- (void)downloadFirmwareForHardware:(NSString*)Hw {
    [_lock lock];
    for (WLFirmwareInfo *infor in _pFWInfos){
        if ([[infor getHardwareVersion] isEqualToString:Hw]) {
            //[self performSelector:@selector(DownloadFromServer)onThread:UpgradeManagerThread withObject:infor waitUntilDone:NO];
            [_lock unlock];
            WLFirmwareStatus s = [infor getStatus];
            if (s == WLFirmwareStatusDownloaded) {
                //todo
            } else if (s == WLFirmwareStatusDownloading) {
                //todo
                [infor DownloadFromServer:YES];
            } else if (s == WLFirmwareStatusNotFound) {
                //todo
            } else if (s == WLFirmwareStatusIdle || s == WLFirmwareStatusFailed) {
                [infor DownloadFromServer:YES];
            }
            return;
        }
    }
    [_lock unlock];
}

- (void)saveFirmwareInfo:(WLFirmwareInfo *)fwInfo {
    [_lock lock];
    
    WLFirmwareInfo *theSameInfo = nil;
    
    for (WLFirmwareInfo *infor in _pFWInfos) {
        if ([[infor getHardwareVersion] isEqualToString:[fwInfo getHardwareVersion]] && [[infor getLatestFirmwareVersion] isEqualToString:[fwInfo getLatestFirmwareVersion]]) {
            theSameInfo = infor;
            break;
        }
    }
    
    if (theSameInfo == nil) {
        [_pFWInfos addObject:fwInfo];
        [_lock unlock];
        [self SaveFwInfoConfig];
        return;
    }
    
    [_lock unlock];
}

- (void)downloadFirmwareForInfo:(WLFirmwareInfo *)fwInfo {
    [_lock lock];
    
    WLFirmwareInfo *theSameInfo = nil;
    
    for (WLFirmwareInfo *infor in _pFWInfos){
        if ([[infor getHardwareVersion] isEqualToString:[fwInfo getHardwareVersion]] && [[infor getLatestFirmwareVersion] isEqualToString:[fwInfo getLatestFirmwareVersion]]) {
            theSameInfo = infor;
            break;
        }
    }
    
    if (theSameInfo == nil) {
        [fwInfo setDelegate:self];
        [_pFWInfos addObject:fwInfo];
        [_lock unlock];
        //        [self downloadFirmwareForHardware:fwInfo.getHardwareVersion];
        [fwInfo DownloadFromServer:YES];
        return;
    } else {
        WLFirmwareStatus status = [theSameInfo getStatus];
        
        if (status == WLFirmwareStatusIdle || status == WLFirmwareStatusFailed) {
            [theSameInfo setDelegate:self];
            [_lock unlock];
            //            [self downloadFirmwareForHardware:fwInfo.getHardwareVersion];
            [theSameInfo DownloadFromServer:YES];
            return;
        }
    }
    
    [_lock unlock];
}

- (WLFirmwareStatus)checkFirmwareStatusFor:(NSString*)Hw {
    [_lock lock];
    for (WLFirmwareInfo *infor in _pFWInfos){
        if ([[infor getHardwareVersion] isEqualToString:Hw]) {
            [_lock unlock];
            return [infor getStatus];
        }
    }
    [_lock unlock];
    return WLFirmwareStatusNotFound;
}
- (int)CheckAccessableFor:(NSString*)Hw {
    [_lock lock];
    for (WLFirmwareInfo *infor in _pFWInfos) {
        if ([[infor getHardwareVersion] isEqualToString:Hw]) {
            [_lock unlock];
            return [infor CheckAccessable];
        }
    }
    [_lock unlock];
    return -1;
}
- (void)checkFromServer {
    bCheckDone = NO;
//    bTras2SomeCamera = NO;
}

-(SCUpgradeClient *)clientFor:(WLCameraDevice *)camera {
    for (SCUpgradeClient* cli in _pClinets) {
        if ([cli.getDevice.sn isEqualToString:camera.sn]) {
            return cli;
        }
    }
    return nil;
}

- (BOOL)isUpgradingCamera:(WLCameraDevice *)camera {
    SCUpgradeClient *upgradeClient = [self clientFor:camera];
    if (upgradeClient != nil) {
        return upgradeClient.isUpgrading;
    }
    return false;
}

- (void)addCamera:(WLCameraDevice*)camera {
    [_lock lock];
    for (SCUpgradeClient* cli in _pClinets) {
        if ([cli.getDevice.sn isEqualToString:camera.sn]) {
            [cli setCliDele:self];
            [cli updateCamera:camera];
            if ([cli isUpgrading]){
                [camera setFirmwareUpgradeDelegate:cli];
            }
            [_lock unlock];
            return;
        }
    }
    SCUpgradeClient *cli = [[SCUpgradeClient alloc] initWithCamera:camera];
    [cli setCliDele:self];
    [_pClinets addObject:cli];
    [_lock unlock];
    
}
- (void)removeCamera:(WLCameraDevice*)camera {
    [_lock lock];
    NSArray *clients = [NSArray arrayWithArray:_pClinets];
    for (SCUpgradeClient* cli in clients) {
        if ([cli.getDevice.sn isEqualToString:camera.sn]) {
            if (pTransferClient == cli){
                [cli cancel];
                pTransferClient = nil;
                bTras2SomeCamera = NO;
                for (id<WLFirmwareUpgradeManagerDelegate> del in _pDelegate) {
                    if ([del respondsToSelector:@selector(firmwareUpgradeManager:sendFirmwareToCamera:finish:)]) {
                        dispatch_async( dispatch_get_main_queue(), ^{
                            [del firmwareUpgradeManager:self sendFirmwareToCamera:camera finish:NO];
                        });
                    }
                }
            }
            [_pClinets removeObject:cli];
            break;
        }
    }
    [_lock unlock];
}

- (void)addDelegate:(id<WLFirmwareUpgradeManagerDelegate>)delegate {
    [_lock lock];
    for (id<WLFirmwareUpgradeManagerDelegate> del in _pDelegate) {
        if (del == delegate) {
            [_lock unlock];
            return;
        }
    }
    [_pDelegate addObject:delegate];
    [_lock unlock];
}

- (void)removeDelegate:(id<WLFirmwareUpgradeManagerDelegate>)delegate {
    [_lock lock];
    NSArray* arr = [_pDelegate copy];
    for (id<WLFirmwareUpgradeManagerDelegate> del in arr) {
        if (del == delegate){
            [_pDelegate removeObject:del];
        }
    }
    [_lock unlock];
}

- (void)doUpgradeForCamera:(WLCameraDevice*)camera {
    SCUpgradeClient* pclient = nil;
    NSString *FWfile = nil;
    NSString *md5 = nil;
    
    [_lock lock];
    
    for (SCUpgradeClient* cli in _pClinets) {
        if ([cli getDevice] == camera){
            pclient = cli;
            break;
        }
    }
    
    for (WLFirmwareInfo* info in _pFWInfos) {
        if ([[info getHardwareVersion] isEqualToString:[camera.hardwareModel stringByAppendingString: self.getBetaFirmware ? @"_BETA" : @""]]) {
            FWfile = [info getLocalFWFile];
            md5 = [info getFWmd5];
            break;
        }
    }
    
    if (FWfile == nil){
        for (id<WLFirmwareUpgradeManagerDelegate> del in _pDelegate) {
            if ([del respondsToSelector:@selector(firmwareUpgradeManager:sendFirmwareToCamera:finish:)]) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [del firmwareUpgradeManager:self sendFirmwareToCamera:camera finish:NO];
                });
            }
        }
    }
    
    [_lock unlock];
    
    if (FWfile != nil){
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [pclient sendFWtoCamera:FWfile md5:md5];
    }
}

- (void)doUpgradeForCamera:(WLCameraDevice *)camera withFirmwareInfo:(WLFirmwareInfo *)fwInfo {
    [_lock lock];
    
    SCUpgradeClient* pclient = nil;
    NSString *fwFile = [fwInfo getLocalFWFile];
    
    for (SCUpgradeClient* cli in _pClinets) {
        if ([cli getDevice] == camera){
            pclient = cli;
            break;
        }
    }
    
    if (fwFile == nil){
        for (id<WLFirmwareUpgradeManagerDelegate> del in _pDelegate) {
            if ([del respondsToSelector:@selector(firmwareUpgradeManager:sendFirmwareToCamera:finish:)]) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [del firmwareUpgradeManager:self sendFirmwareToCamera:camera finish:NO];
                });
            }
        }
    }
    
    [_lock unlock];
    
    if (fwFile != nil){
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        if (camera.communicationProtocolVersion == CommunicationProtocolVersionCamClient) {
            [pclient sendFWtoCamera:fwFile md5:[fwInfo getFWmd5]];
        } else {
            self.firmwareUpdater = [[WLEvcamFirmwareUpdater alloc] initWithCameraDevice:camera];
            
            __weak typeof(self) weakSelf = self;
            [self.firmwareUpdater transferFirmware:fwFile withProgress:^(NSInteger progress) {
                NSLog(@"transferring firmware: %ld%%", (long)progress);
                
                __strong typeof(weakSelf) strongself = weakSelf;
                
                [strongself->_lock lock];
                
                for (id<WLFirmwareUpgradeManagerDelegate> del in strongself->_pDelegate){
                    if ([del respondsToSelector:@selector(firmwareUpgradeManager:sendFirmwareToCamera:process:)]){
                        dispatch_async( dispatch_get_main_queue(), ^{
                            [del firmwareUpgradeManager:self sendFirmwareToCamera:camera process:(int)progress];
                        });
                    }
                }
                [strongself->_lock unlock];
            } successHandler:^{
                NSLog(@"done transferring firmware");
                
                __strong typeof(weakSelf) strongself = weakSelf;
                
                [strongself->_lock lock];
                for (id<WLFirmwareUpgradeManagerDelegate> del in strongself->_pDelegate){
                    if ([del respondsToSelector:@selector(firmwareUpgradeManager:sendFirmwareToCamera:finish:)]){
                        dispatch_async( dispatch_get_main_queue(), ^{
                            [del firmwareUpgradeManager:self sendFirmwareToCamera:camera finish:YES];
                        });
                    }
                }
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                [strongself->_lock unlock];
            } failureHandler:^(NSInteger errorCode) {
                NSLog(@"transferring firmware failed: %ld", (long)errorCode);
                
                __strong typeof(weakSelf) strongself = weakSelf;
                
                [strongself->_lock lock];
                
                for (id<WLFirmwareUpgradeManagerDelegate> del in strongself->_pDelegate){
                    if ([del respondsToSelector:@selector(firmwareUpgradeManager:sendFirmwareToCamera:finish:)]){
                        dispatch_async( dispatch_get_main_queue(), ^{
                            [del firmwareUpgradeManager:self sendFirmwareToCamera:camera finish:NO];
                        });
                    }
                }
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                
                [strongself->_lock unlock];
            }];
        }
    }
}

- (long)sizeofNewFirmwareFromCamera:(WLCameraDevice*)camera {
    long size = 0;
    NSString *hw = camera.hardwareModel;
    if ([hw isEqualToString:@""]) {
        return -1;
    }
    [_lock lock];
    for (WLFirmwareInfo* info in _pFWInfos) {
        if ([[info getHardwareVersion] isEqualToString:camera.hardwareModel]) {
            size = [info getFirmwareSize];
            break;
        }
    }
    [_lock unlock];
    return size;
}
- (int)doCheckSpace:(int)MB forCamera:(WLCameraDevice*)camera {
    int enough = 0;
    NSString *hw = camera.hardwareModel;
    if ([hw isEqualToString:@""]) {
        return -1;
    }
    [_lock lock];
    for (WLFirmwareInfo* info in _pFWInfos) {
        if ([[info getHardwareVersion] isEqualToString:camera.hardwareModel] == NO) {
            continue;
        }
        if ([info getFirmwareSize]/1000000 > (MB - 2)) {
            enough = (int)([info getFirmwareSize]/1000000)- (MB - 2);
        } else {
            enough = 0;
        }
        break;
    }
    [_lock unlock];
    return enough;
}

- (BOOL)noDownloadTask {
    BOOL ret = YES;
    for (WLFirmwareInfo* info in _pFWInfos) {
        if ([info getStatus] == WLFirmwareStatusDownloading) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (void)resetLocalFiles {
    if (bCheckDone == YES || bTras2SomeCamera || [self noDownloadTask]) {
        for (WLFirmwareInfo* info in _pFWInfos){
            [info DeleteLocalFW];
        }
        [_pFWInfos removeAllObjects];
        [self SaveFwInfoConfig];
        [self checkFromServer];
    }
    
}
- (NSString*)basePath {
    NSString* dict = [[NSHomeDirectory()stringByAppendingString:@"/Documents/"]
                      stringByAppendingString:@"/FW"];
    return dict;
}

- (void)downloadExternalFirmwareFromUrl:(NSString*)url {
    [_lock lock];
    // remove external firmwares
    for (WLFirmwareInfo *infor in _pFWInfos) {
        if ([infor isFromExternal]) {
            [infor DeleteLocalFW];
            [_pFWInfos removeObject:infor];
            break;
        }
    }
    //
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:url, @HARDWARE_EXTERNAL, @(YES), nil]
                                                     forKeys:[NSArray arrayWithObjects:@DEVICE_FWUPDATE_URL, @DEVICE_FWUPDATE_DEVICE_MODEL, @DEVICE_fWUPDATE_ISFROMEXTERNAL, nil]];
    WLFirmwareInfo *newinfo = [[WLFirmwareInfo alloc]initWithDictionary:dict];
    [newinfo DownloadFromServer:YES];
    [newinfo setDelegate:self];
    [_pFWInfos addObject:newinfo];
    [_lock unlock];
    [self SaveFwInfoConfig];
}

- (void)removeExternalFirmware {
    [_lock lock];
    // remove external firmwares
    for (WLFirmwareInfo *infor in _pFWInfos) {
        if ([infor isFromExternal] ||
            [[infor getHardwareVersion] isEqualToString:@HARDWARE_EXTERNAL]) {
            [infor DeleteLocalFW];
            [_pFWInfos removeObject:infor];
            break;
        }
    }
    [_lock unlock];
    [self SaveFwInfoConfig];
}

- (BOOL)isExternalFirmwareValid {
    BOOL ret = NO;
    [_lock lock];
    // remove external firmwares
    for (WLFirmwareInfo *infor in _pFWInfos) {
        if ([infor isFromExternal]) {
            if (infor.downloadDate != 0 &&
                [NSDate new].timeIntervalSince1970 -infor.downloadDate < 5*24*3600) {
                ret = true;
            }
            break;
        }
    }
    [_lock unlock];
    return ret;
}

- (void)fetchFirmwareWithBlock:(void(^)(BOOL done, NSError *err, NSDictionary *msg))completion {
    NSString *url = [NSString stringWithFormat:@"%@/api/v1.0/firmwares", self.server] ;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"RESPONSE: %@",response);
        NSLog(@"Get Firmware Success");
        if (!error) {
            // Success
            NSError *jsonError;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                // Error Parsing JSON
                completion(NO, jsonError, nil);
            } else {
                // Success Parsing JSON
                // Log NSDictionary response:
                //NSLog(@"%@",jsonResponse);
                if ([jsonResponse respondsToSelector:@selector(objectForKey:)]) {
                    NSNumber *code = [jsonResponse objectForKey:@"code"];
                    if (code != nil && code.intValue > 0) {
                        completion(NO, nil, jsonResponse);
                    } else {
                        completion(YES, nil, jsonResponse);
                    }
                } else {
                    completion(YES, nil, jsonResponse);
                }
            }
        } else {
            // Fail
            NSLog(@"error : %@", error.description);
            completion(NO, error, nil);
        }
    }] resume ];
}

- (void)doCheckFromServer {
    [_lock lock];
    for (SCUpgradeClient* client in _pClinets) {
        if ([client isUpgrading]){
            [_lock unlock];
            return;
        }
    }
    for (WLFirmwareInfo* info in _pFWInfos){
        if ([info getStatus] == WLFirmwareStatusDownloading) {
            [_lock unlock];
            return;
        }
    }
    [_lock unlock];

    __weak typeof(self) weakSelf = self;
    [self fetchFirmwareWithBlock:^(BOOL done, NSError *err, NSDictionary *msg) {
        __strong typeof(weakSelf) strongself = weakSelf;

        strongself->bChecking = NO;
        strongself->bCheckDone = YES;

        BOOL updated = NO;

        if (done) {
            NSArray* array = (NSArray*)msg;
            NSLog(@"get %d fws from server", (int)[array count]);
            for (NSDictionary* pfw in array) {
                NSString *tmp = [pfw objectForKey:@DEVICE_FWUPDATE_DEVICE_MODEL];
                if (tmp != Nil){
                    NSLog(@"%d, model: %@", (int)[array indexOfObject:pfw], tmp);
                }else{
                    continue;
                }
                tmp = [pfw objectForKey:@DEVICE_FWUPDATE_BSP_VERSION];
                if (tmp != Nil){
                    NSLog(@"%d, bsp version: %@", (int)[array indexOfObject:pfw], tmp);
                }else{
                    continue;
                }
                tmp = [pfw objectForKey:@DEVICE_FWUPDATE_API_VERSION];
                if (tmp != Nil){
                    NSLog(@"%d, api version: %@", (int)[array indexOfObject:pfw], tmp);
                }else{
                    continue;
                }
                tmp = [pfw objectForKey:@DEVICE_FWUPDATE_URL];
                if (tmp != Nil){
                    //NSLog(@"%d, url: %@", (int)[array indexOfObject:pfw], tmp);
                }else{
                    continue;
                }
                tmp = [pfw objectForKey:@DEVICE_FWUPDATE_SIZE];
                if (tmp != Nil){
                    NSNumber* val = (NSNumber*)tmp;
                    NSLog(@"%d, size: %d", (int)[array indexOfObject:pfw], [val intValue]);
                }else{
                    continue;
                }
                tmp = [pfw objectForKey:@DEVICE_FWUPDATE_DSCRPT];
                if (tmp != Nil){
                    //NSLog(@"%d, description: %@", (int)[array indexOfObject:pfw], tmp);
                }else{
                    continue;
                }
                tmp = [pfw objectForKey:@DEVICE_fWUPDATE_MD5];
                if (tmp != Nil){
                    NSLog(@"%d, md5: %@", (int)[array indexOfObject:pfw], tmp);
                }else{
                    continue;
                }
                
                BOOL exist = NO;
                [strongself->_lock lock];
                for (WLFirmwareInfo* info in strongself->_pFWInfos) {
                    if (([info isFromExternal] == false) &&
                        [[info getHardwareVersion] isEqualToString:[pfw objectForKey:@DEVICE_FWUPDATE_DEVICE_MODEL]]){
                        if([info isNotSameWith:pfw]) {
                            if ([info getStatus] == WLFirmwareStatusDownloading) {
                                [info stopDownloading];
                            }
                            [info DeleteLocalFW];
                            [strongself->_pFWInfos removeObject:info];
                            break;
                        } else {
                            if ([info.getUpgradeDescription.description isEqualToString:[[pfw objectForKey:@DEVICE_FWUPDATE_DSCRPT] description]] == NO) {
                                [info updateUpgradeDescription:[pfw objectForKey:@DEVICE_FWUPDATE_DSCRPT]];
                                updated = YES;
                            }
                            exist = YES;
                            break;
                        }
                    }
                }
                if (exist == NO){
                    WLFirmwareInfo *newinfo = [[WLFirmwareInfo alloc]initWithDictionary:pfw];
                    [newinfo setDelegate:self];
                    [strongself->_pFWInfos addObject:newinfo];
                    updated = YES;
                } else {
                    
                }
                [strongself->_lock unlock];
            }
            if (updated) {
                [self SaveFwInfoConfig];
            }
//            if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus==ReachableViaWiFi) {
//                [[DeviceManager pInstance] checkUpgradeForSavedCameras];
//            }
        }
        for (id<WLFirmwareUpgradeManagerDelegate> del in strongself->_pDelegate){
            if (del && [del respondsToSelector:@selector(firmwareUpgradeManager:firmwareCheckDone:)]) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [del firmwareUpgradeManager:self firmwareCheckDone:done];
                });
            }
        }
    }];
}

- (void)SaveFwInfoConfig {
    [_lock lock];
    NSError *err;
    NSString* dict = [[NSHomeDirectory()stringByAppendingString:@"/Documents/"]
                      stringByAppendingString:@"FW"];
    NSString *filePath = [dict stringByAppendingFormat:FWInfoConfig];
    NSMutableArray *InfoDicts = [[NSMutableArray alloc]init];
    for (WLFirmwareInfo* info in _pFWInfos){
        NSDictionary* dict = [info generateDictionaryObject];
        if(dict != Nil){
            [InfoDicts addObject:dict];
        }
    }
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:InfoDicts, nil]
                                                          forKeys:[NSArray arrayWithObjects:@"FwInfos", nil]];
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                                  options:0
                                                                    error:&err];
    if(plistData){
        NSError* error1;
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:Nil];
        }
        [plistData writeToFile:filePath options:NSDataWritingAtomic error:&error1];
    } else {
        //NSLog(error);
    }
    [_lock unlock];
}

- (void)LoadConfig {
    [_lock lock];
    NSString* dict = [[NSHomeDirectory()stringByAppendingString:@"/Documents/"]
                      stringByAppendingString:@"FW"];
    BOOL isdict = NO;
    BOOL bFind = [[NSFileManager defaultManager] fileExistsAtPath:dict isDirectory:&isdict];
    if (!bFind || !isdict){
        [[NSFileManager defaultManager] createDirectoryAtPath:dict withIntermediateDirectories:NO attributes:nil error:nil];
    }
    do {
        NSString *filePath = [dict stringByAppendingFormat:FWInfoConfig];
        {//debug to delete config
            //[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            //return;
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            break;
        }
        NSError *errorDesc = nil;
        NSPropertyListFormat format;
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListWithData:plistXML
                                              options:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              error:&errorDesc];
        if (!temp){
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, (int)format);
            break;
        }
        NSArray *pArray = [temp objectForKey:@"FwInfos"];
        for(NSDictionary *pd in pArray){
            WLFirmwareInfo *info = [[WLFirmwareInfo alloc]initWithDictionary:pd];
            [info setDelegate:self];
            [_pFWInfos addObject:info];
        }
    } while (0);
    [_lock unlock];
}

- (void)FwDownloading:(int)process downloaded:(long)size forHw:(NSString*)hw {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        if (process == 0 || process == 200){
            [self SaveFwInfoConfig];
            if (process==200) {
                self.fwToDownload = nil;
            }
        }
        for (id<WLFirmwareUpgradeManagerDelegate> del in self->_pDelegate){
            if ([del respondsToSelector:@selector(firmwareUpgradeManager:firmwareDownloading:downloaded:forHardware:)]){
//                [del FwDownloading:process downloaded:size forHw:hw];
                [del firmwareUpgradeManager:self firmwareDownloading:process downloaded:size forHardware:hw];
            }
        }
    }];
}

- (void)FwServerCannotAccessforHw:(NSString*)hw {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        [self SaveFwInfoConfig];
        [self->_lock lock];
        for (id<WLFirmwareUpgradeManagerDelegate> del in self->_pDelegate){
            if ([del respondsToSelector:@selector(firmwareUpgradeManager:firmwareServerCannotAccessforHardware:)]){
                [del firmwareUpgradeManager:self firmwareServerCannotAccessforHardware:hw];
            }
        }
        [self->_lock unlock];
    }];
}
- (void)FwDownloadErrorforHw:(NSString*)hw {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        [self SaveFwInfoConfig];
        [self->_lock lock];
        for (id<WLFirmwareUpgradeManagerDelegate> del in self->_pDelegate){
            if ([del respondsToSelector:@selector(firmwareUpgradeManager:firmwareDownloadErrorForHardware:)]){
                [del firmwareUpgradeManager:self firmwareDownloadErrorForHardware:hw];
            }
        }
        [self->_lock unlock];
    }];
}

- (void)RdyToUpgradeforCamera:(SCUpgradeClient*)camera {
    [_lock lock];
    if (bTras2SomeCamera == NO){
        pTransferClient = camera;
        bTras2SomeCamera = YES;
    } else if (pTransferClient != camera) {
        for (id<WLFirmwareUpgradeManagerDelegate> del in _pDelegate){
            if ([del respondsToSelector:@selector(firmwareUpgradeManagerTooManyTasks:)]){
                dispatch_async( dispatch_get_main_queue(), ^{
                    [del firmwareUpgradeManagerTooManyTasks:self];
                });
            }
        }
    }
    [_lock unlock];
}
- (void)GoonUpgradeforCamera:(SCUpgradeClient*)camera {
}
- (void)UpgradeDoneforCamera:(SCUpgradeClient*)camera {
    [_lock lock];
    if (bTras2SomeCamera && pTransferClient==camera){
        pTransferClient = nil;
        bTras2SomeCamera = NO;
    }
    for (id<WLFirmwareUpgradeManagerDelegate> del in _pDelegate){
        if ([del respondsToSelector:@selector(firmwareUpgradeManager:sendFirmwareToCamera:finish:)]){
            dispatch_async( dispatch_get_main_queue(), ^{
                [del firmwareUpgradeManager:self sendFirmwareToCamera:[camera getDevice] finish:YES];
            });
        }
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [_lock unlock];
}
- (void)UpgradeFailedforCamera:(SCUpgradeClient*)camera {
    [_lock lock];
    if (bTras2SomeCamera && pTransferClient==camera){
        pTransferClient = nil;
        bTras2SomeCamera = NO;
    }
    for (id<WLFirmwareUpgradeManagerDelegate> del in _pDelegate){
        if ([del respondsToSelector:@selector(firmwareUpgradeManager:sendFirmwareToCamera:finish:)]){
            dispatch_async( dispatch_get_main_queue(), ^{
                [del firmwareUpgradeManager:self sendFirmwareToCamera:[camera getDevice] finish:NO];
            });
        }
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [_lock unlock];
}

- (void)Upgradeprocess:(int)process Camera:(SCUpgradeClient*)camera {
    [_lock lock];
    for (id<WLFirmwareUpgradeManagerDelegate> del in _pDelegate){
        if ([del respondsToSelector:@selector(firmwareUpgradeManager:sendFirmwareToCamera:process:)]){
            dispatch_async( dispatch_get_main_queue(), ^{
                [del firmwareUpgradeManager:self sendFirmwareToCamera:[camera getDevice] process:process];
            });
        }
    }
    [_lock unlock];
}
#pragma mark - Notifications

- (void) appWillEnterForeground {
    for (WLFirmwareInfo *infor in _pFWInfos) {
        [infor onEnterForeground];
    }
}
//
- (void) appDidEnterBackground {
    for (WLFirmwareInfo *infor in _pFWInfos) {
        [infor onEnterBackground];
    }
}
@end
