//
//  JPush.m
//  JPush
//
//  Created by ys on 2020/8/14.
//

#import "JPush.h"
#import <AdSupport/AdSupport.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>

@interface JPush ()<JPUSHGeofenceDelegate,PKPushRegistryDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation JPush

+ (id)shared {
    static JPush * instance = nil;
    if (instance == nil) {
        instance = [[JPush alloc] init];
    }
    return instance;
}

//其他JPush的功能代码
- (void)initOthers:(NSString*)appkey launchOptions:(NSDictionary *)launchOptions {
    //检测SDK连接等通知
    [self registerObserver];
    self.appkey = appkey;
    //如果使用地理围栏，请先获取地理位置权限。
    [self getLocationAuthority];
    //如果使用地理围栏功能，需要注册地理围栏代理
    [JPUSHService registerLbsGeofenceDelegate:self withLaunchOptions:launchOptions];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            self.registrationID = registrationID;
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    //注册 voip
    [self voipRegistration];
    // 检测通知授权情况。可选项，不一定要放在此处，可以运行一定时间后再调用
    [self performSelector:@selector(checkNotificationAuthorization) withObject:nil afterDelay:10];
}

- (void)registerObserver {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJPFNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJPFNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
}


//与极光服务端建立长连接
- (void)networkDidSetup:(NSNotification *)notification {
    self.jpushState = @"connected";
    NSLog(@"connected");
}

//长连接关闭
- (void)networkDidClose:(NSNotification *)notification {
    self.jpushState = @"not connected。。。";
    NSLog(@"not connected。。。");
}

//注册成功
- (void)networkDidRegister:(NSNotification *)notification {
    self.jpushState = @"registered";
    NSLog(@"registered");
    
}

//登录成功
- (void)networkDidLogin:(NSNotification *)notification {
    self.jpushState = @"Has logged";
    NSLog(@"Has logged");
}

- (void)deviceToken:(NSData *)deviceToken {
    const unsigned int *tokenBytes = [deviceToken bytes];
    NSString *tokenString = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"Device Token: %@", tokenString);
    self.deviceToken = tokenString;

}

/**
 注册Voip服务（以下示例代码，开发者可根据需要修改）JPush 3.3.2 JCore 2.2.4 及以上支持Voip功能
 */
- (void)voipRegistration{
  dispatch_queue_t mainQueue = dispatch_get_main_queue();
  PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:mainQueue];
  voipRegistry.delegate = self;
  // Set the push type to VoIP
  voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}


#pragma mark- JPUSHRegisterDelegate
- (void)willPresentNotification:(UNNotification *)notification {
    NSDictionary * userInfo = notification.request.content.userInfo;
      
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
  
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
       // [JPUSHService handleRemoteNotification:userInfo];
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response {
  
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
  
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
  
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
       
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }

}

#pragma mark- PKPushRegistryDelegate

/// 系统返回VoipToken,上报给极光服务器
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type{
    [JPUSHService registerVoipToken:pushCredentials.token];
    NSLog(@"Voip Token: %@", pushCredentials.token);
}

/**
 * 接收到Voip推送信息，并向极光服务器上报（iOS 8.0 - 11.0）
 */
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type{
  // 提交回执给极光服务器
  [JPUSHService handleVoipNotification:payload.dictionaryPayload];
  NSLog(@"Voip Payload: %@, %@",payload,payload.dictionaryPayload);
  // [ 示例代码 ] 发起一个本地通知
  JPushNotificationContent *content = [[JPushNotificationContent alloc] init];;
  content.title = @"test title";
  content.body = @"Test content";
  JPushNotificationTrigger *triggger = [[JPushNotificationTrigger alloc] init];
  triggger.timeInterval = 3;
  JPushNotificationRequest *request = [[JPushNotificationRequest alloc] init];
  request.content = content;
  request.trigger = triggger;
  request.requestIdentifier = @"test";
  request.completionHandler = ^(id result) {
    if (result) {
      NSLog(@"添加 timeInterval 通知成功 --- %@", result);
    }else {
      NSLog(@"添加 timeInterval 通知失败 --- %@", result);
    }
  };
  [JPUSHService addNotification:request];
}

/**
 * 接收到Voip推送信息，并向极光服务器上报（iOS 11.0 以后）
 */
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void(^)(void))completion{
  // 提交回执给极光服务器
  [JPUSHService handleVoipNotification:payload.dictionaryPayload];
  NSLog(@"Voip Payload: %@, %@",payload,payload.dictionaryPayload);
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
  if (![dic count]) {
    return nil;
  }
  NSString *tempStr1 =
      [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                   withString:@"\\U"];
  NSString *tempStr2 =
      [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
  NSString *tempStr3 =
      [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
  NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
  NSString *str =
      [NSPropertyListSerialization propertyListFromData:tempData
                                       mutabilityOption:NSPropertyListImmutable
                                                 format:NULL
                                       errorDescription:NULL];
  return str;
}
#pragma mark -JPUSHGeofenceDelegate
//进入地理围栏区域
- (void)jpushGeofenceIdentifer:(NSString *)geofenceId didEnterRegion:(NSDictionary *)userInfo error:(NSError *)error {
  NSLog(@"进入地理围栏区域");
  if (error) {
    NSLog(@"error = %@",error);
    return;
  }
  if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
    [self testAlert:userInfo];
  }else{
    // 进入后台
    [self geofenceBackgroudTest:userInfo];
  }
}
//离开地理围栏区域
- (void)jpushGeofenceIdentifer:(NSString *)geofenceId didExitRegion:(NSDictionary *)userInfo error:(NSError *)error {
  NSLog(@"离开地理围栏区域");
  if (error) {
    NSLog(@"error = %@",error);
    return;
  }
  if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
    [self testAlert:userInfo];
  }else{
    // 进入后台
    [self geofenceBackgroudTest:userInfo];
  }
}
//
- (void)geofenceBackgroudTest:(NSDictionary * _Nullable)userInfo{
  //静默推送：
  if(!userInfo){
    NSLog(@"静默推送的内容为空");
    return;
  }
  //TODO
  
}

- (void)testAlert:(NSDictionary*)userInfo{
  if(!userInfo){
    NSLog(@"messageDict 为 nil ");
    return;
  }
  NSString *title = userInfo[@"title"];
  NSString *body = userInfo[@"content"];
  if (title &&  body ) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
  }
}
#pragma mark location
- (void)getLocationAuthority{
  _locationManager= [[CLLocationManager alloc] init];
  if(@available(iOS 8.0, *)) {
    [_locationManager requestAlwaysAuthorization];
  }else{
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
      NSLog(@"kCLAuthorizationStatusNotDetermined");
    }
  }
  _locationManager.delegate = (id<CLLocationManagerDelegate>)self;
}
#pragma mark -CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
  if (status != kCLAuthorizationStatusNotDetermined) {
    NSLog(@"Obtained geographic location permission successfully");
  }
}

#pragma mark - 通知权限引导

// 检测通知权限授权情况
- (void)checkNotificationAuthorization {
  [JPUSHService requestNotificationAuthorization:^(JPAuthorizationStatus status) {
    // run in main thread, you can custom ui
    NSLog(@"notification authorization status:%lu", status);
    [self alertNotificationAuthorization:status];
  }];
}

// 通知未授权时提示，是否进入系统设置允许通知，仅供参考
- (void)alertNotificationAuthorization:(JPAuthorizationStatus)status {
//  if (status < JPAuthorizationStatusAuthorized) {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Allow notifications" message:@"Whether to enter the settings to allow notifications？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    [alertView show];
//  }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    if(@available(iOS 8.0, *)) {
      [JPUSHService openSettingsForNotification:^(BOOL success) {
        NSLog(@"open settings %@", success?@"success":@"failed");
      }];
    }
  }
}


@end
