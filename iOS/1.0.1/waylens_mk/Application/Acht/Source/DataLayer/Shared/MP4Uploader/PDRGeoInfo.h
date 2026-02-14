//
//  PDRGeoInfo.h
//  Hachi
//
//  Created by Waylens Administrator on 9/23/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDRGeoInfo : NSObject
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
-(instancetype)initWithDict:(NSDictionary *)dict;
-(void)updateWithDict:(NSDictionary *)dict;
-(NSDictionary *)dict;
@end
