//
//  PDRUploadMoment.m
//  Hachi
//
//  Created by gliu on 15/11/23.
//  Copyright © 2015年 Transee. All rights reserved.
//

#import "PDRUploadMoment.h"

@implementation PDRUploadMoment

- (id)initWithTitle:(NSString*)title Description:(NSString*)desc Tags:(NSArray*)tags {
    self = [super init];
    if (self) {
        self.title = [NSString stringWithString:title];
        self.descriptionString = [NSString stringWithString:desc];
        self.tagArray = [[NSMutableArray alloc] init];
        if (tags) {
            [self.tagArray addObjectsFromArray:tags];
        }
        _shareToYoutube = NO;
        _shareToFaceBook = NO;
    }
    return self;
}

-(NSMutableDictionary *)dict{
    NSMutableDictionary *dict = [@{
                                   @"title": self.title.length?self.title:@"",
                                   @"accessLevel": @"private".uppercaseString,
                                   @"momentType": self.momentType?: @""
                                   } mutableCopy];
    if (self.descriptionString.length>0) {
        dict[@"desc"] = self.descriptionString;
    }
    if (self.tagArray.count>0) {
        dict[@"hashTags"] = self.tagArray;
    }
    dict[@"audioType"] = @(0);
//    if (self.musicSource && self.audioType==WLAudioTypeMusic) {
//        dict[@"musicSource"] = [self.musicSource stringValue];
//    }
    NSMutableArray *providers = [NSMutableArray array];
//    if (self.shareToFaceBook) {
//        [providers addObject:@"facebook"];
//        if ([FBSDKAccessToken currentAccessToken]) {
//            dict[@"facebookToken"] = [FBSDKAccessToken currentAccessToken].tokenString;
//        }
//    }
    if (self.shareToYoutube) {
        [providers addObject:@"youtube"];
    }
    if ([providers count]>0) {
        dict[@"shareProviders"] = providers;
    }
    
    if(self.vehicleMaker) {
        dict[@"vehicleMaker"] = self.vehicleMaker;
    }
    if(self.vehicleModel) {
        dict[@"vehicleModel"] = self.vehicleModel;
    }
    if(self.vehicleYear) {
        dict[@"vehicleYear"] = self.vehicleYear;
    }
    if(self.vehicleDesc) {
        dict[@"vehicleDesc"] = self.vehicleDesc;
    }
    if (self.geoInfo) {
        dict[@"withGeoTag"] = @(YES);
        dict[@"geoInfo"] = [self.geoInfo dict];
    } else {
        dict[@"withGeoTag"] = @(NO);
    }
    return dict;
}

- (void)addTag:(NSString*)tag {
    if ([self.tagArray containsObject:tag] == NO) {
        [self.tagArray addObject:tag];
    }
}

- (void)removeTag:(NSString*)tag {
    if ([self.tagArray containsObject:tag]) {
        [self.tagArray removeObject:tag];
    }
}

- (unsigned long long)totalSize {
    // to override
    return 0;
}

-(NSString *)accessLevelString{
//    if (self.accessLevel==ACCESS_LEVEL_PUBLIC) {
//        return @"public";
//    } else if (self.accessLevel==ACCESS_LEVEL_PROTECT) {
//        return @"protect";
//    } else if (self.accessLevel==ACCESS_LEVEL_PRIVATE) {
        return @"private";
//    } else
//        return @"public";
}

@end
