//
//  ConfigPush.m
//  demoJpush
//
//  Created by TranHoangThanh on 3/2/22.
//

#import <Foundation/Foundation.h>
#import "ConfigPush.h"
#import "JPUSHService.h"
#import "JPush.h"
#import <AdSupport/AdSupport.h>//"
#import <UserNotifications/UserNotifications.h>
//#define APPKEY @"571281eb431b877b3b040adb"


#define APPKEY @"09a08bc5979e34ad7897db84"

@interface ConfigPush ()<JPUSHRegisterDelegate>



@end

@implementation ConfigPush



- (JPUSHRegisterEntity *)pushRegisterEntity {
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    return entity;
}

- (void)jpushInit:(NSDictionary *)launchOptions {
    //【注册通知】通知回调代理（可选）
    [JPUSHService registerForRemoteNotificationConfig:[self pushRegisterEntity] delegate:self];
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //【初始化sdk】
    [JPUSHService setupWithOption:launchOptions appKey:APPKEY
                          channel:@"test"
                 apsForProduction:YES
            advertisingIdentifier:advertisingId];
    //温馨提示：快速集成JPush只需要【注册通知】【初始化sdk】两步即可
    
    //获取registrationId/检测通知授权情况/地理围栏/voip注册/监听连接状态等其他功能
    [[JPush shared] initOthers:APPKEY launchOptions:launchOptions];
}

#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger options))completionHandler {
    
    [self.delegate jpushNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
//     NSDictionary * userInfo = notification.request.content.userInfo;
//    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
     //[[JPush shared] willPresentNotification:notification];
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    
   [self.delegate jpushNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
  
//    NSDictionary * userInfo = response.notification.request.content.userInfo;
//
//    [JPUSHService handleRemoteNotification:userInfo];
//    completionHandler();  // 系统要求执行这个方法
//
//    [[JPush shared] didReceiveNotificationResponse:response];
}
- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
  NSLog(@"receive notification authorization status:%lu, info:%@", status, info);
    [self.delegate jpushNotificationAuthorization:status withInfo:info];
//  [[JPush shared] alertNotificationAuthorization:status];
}

#ifdef __IPHONE_12_0
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification {
    NSString *title = nil;
    if (notification) {
     //   title = @"从通知界面直接进入应用";
        title = @"Go directly to the app from the notification interface";
    }else{
    //    title = @"从系统设置界面进入应用";
        
        title = @"Enter the application from the system settings interface";
    }
    NSLog(@"%@", title);
}
#endif

@end
