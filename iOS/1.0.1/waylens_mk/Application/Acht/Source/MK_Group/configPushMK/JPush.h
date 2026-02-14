//
//  JPush.h
//  JPush
//
//  Created by ys on 2020/8/14.
//

#import <Foundation/Foundation.h>
#import "JPUSHService.h"

//JPush Demo 包含部分功能及简单ui
@interface JPush : NSObject

@property(nonatomic, strong) NSString *appkey;
@property(nonatomic, strong) NSString *registrationID;
@property(nonatomic, strong) NSString *deviceToken;
@property(nonatomic, strong) NSString *jpushState;

+ (JPush *)shared;
//其他功能
- (void)initOthers:(NSString*)appkey launchOptions:(NSDictionary *)launchOptions;
//设置deviceToken
- (void)deviceToken:(NSData *)deviceToken;
// 通知未授权时提示，是否进入系统设置允许通知，仅供参考
- (void)alertNotificationAuthorization:(JPAuthorizationStatus)status;

- (void)willPresentNotification:(UNNotification *)notification;
- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response;

/// 检测通知权限授权情况
- (void)checkNotificationAuthorization;

@end
