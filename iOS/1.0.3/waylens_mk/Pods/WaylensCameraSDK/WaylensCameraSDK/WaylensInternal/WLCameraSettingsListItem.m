//
//  WLCameraSettingsListItem.m
//  WaylensCameraSDK
//
//  Created by forkon on 2020/11/11.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import "WLCameraSettingsListItem.h"

@implementation WLCameraSettingsListItem

+ (instancetype) itemWithTitle:(NSString*)title value:(NSInteger)value {
    return [[WLCameraSettingsListItem alloc] initWithTitle:title value:value];
}

- (instancetype) initWithTitle:(NSString*)title value:(NSInteger)value {
    self = [super init];
    if (self) {
        _title = title;
        _value = value;
    }
    return self;
}
@end
