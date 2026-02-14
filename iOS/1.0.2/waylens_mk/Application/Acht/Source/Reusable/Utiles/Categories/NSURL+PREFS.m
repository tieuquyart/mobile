//
//  NSURL+PREFS.m
//  Hachi
//
//  Created by lzhu on 2/19/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSURL+PREFS.h"
#import <UIKit/UIKit.h>

@implementation NSURL (PREFS)

+ (NSURL*) appSettings {
    return [NSURL URLWithString:UIApplicationOpenSettingsURLString];
}

@end
