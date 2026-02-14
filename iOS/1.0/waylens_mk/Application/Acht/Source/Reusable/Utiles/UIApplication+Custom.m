//
//  UIApplication.m
//  Hachi
//
//  Created by gliu on 15/11/21.
//  Copyright © 2015年 Transee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIApplication+Custom.h"

@implementation UIApplication (Custom)

- (void)openWiFiSettings {
    [self openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
}

- (void)openAppSettings {
    [self openURL:[NSURL URLWithString:@"app-settings:"]];
}

@end
