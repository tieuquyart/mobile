//
//  ConfigPush.h
//  demoJpush
//
//  Created by TranHoangThanh on 3/2/22.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "JPUSHService.h"

@protocol ConfigPushMKDelegate <NSObject>
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger options))completionHandler;
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler;
- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info ;
@end

@interface ConfigPush : NSObject

  @property (nonatomic, weak) id<ConfigPushMKDelegate> delegate;
- (void)jpushInit:(NSDictionary *)launchOptions;

@end
