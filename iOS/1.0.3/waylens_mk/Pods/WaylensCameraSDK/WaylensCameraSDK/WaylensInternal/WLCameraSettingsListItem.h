//
//  WLCameraSettingsListItem.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/11/11.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLCameraSettingsListItem: NSObject
@property (strong, nonatomic, readonly, nonnull) NSString *title;      //for UI
@property (assign, nonatomic, readonly) NSUInteger value;      //store some enum value or index

+ (nonnull instancetype)itemWithTitle:(nonnull NSString *)title value:(NSInteger)value;
@end
