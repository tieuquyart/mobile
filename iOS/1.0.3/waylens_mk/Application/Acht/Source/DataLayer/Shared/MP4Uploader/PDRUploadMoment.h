//
//  PDRUploadMoment.h
//  Hachi
//
//  Created by gliu on 15/11/23.
//  Copyright © 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDRGeoInfo.h"

@interface PDRUploadMoment : NSObject
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* descriptionString;
@property (strong, nonatomic) NSMutableArray* tagArray;
@property (assign, nonatomic) NSInteger momentID;
//@property (assign, nonatomic) WayLensMomentAccessLevel accessLevel;
@property (strong, nonatomic) NSData* thumbnailData;
@property (strong, nonatomic) NSNumber *musicSource;
//@property (assign, nonatomic) WLAudioType audioType; // 0: origianl audio track, 1: music source 2: mute
@property (strong, nonatomic) NSDictionary *overlay;
@property (assign, nonatomic) BOOL shareToFaceBook;
@property (assign, nonatomic) BOOL shareToYoutube;

@property (strong, nonatomic) NSString *vehicleMaker;
@property (strong, nonatomic) NSString *vehicleModel;
@property (strong, nonatomic) NSNumber *vehicleYear;
@property (strong, nonatomic) NSString *vehicleDesc;
@property (strong, nonatomic) PDRGeoInfo *geoInfo;
@property (strong, nonatomic) NSString *momentType;

- (id)initWithTitle:(NSString*)title Description:(NSString*)desc Tags:(NSArray*)tags;
- (NSMutableDictionary *)dict;
- (void)addTag:(NSString*)tag;
- (void)removeTag:(NSString*)tag;
- (unsigned long long)totalSize;
- (NSString *)accessLevelString;

@end
