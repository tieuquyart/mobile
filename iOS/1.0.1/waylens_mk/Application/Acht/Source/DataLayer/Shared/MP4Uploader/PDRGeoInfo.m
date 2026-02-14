//
//  PDRGeoInfo.m
//  Hachi
//
//  Created by Waylens Administrator on 9/23/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "PDRGeoInfo.h"
@implementation PDRGeoInfo
-(instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        _country = dict[@"country"];
        _region = dict[@"region"];
        _city = dict[@"city"];
        _address = dict[@"address"];
        _longitude = [dict[@"longitude"] doubleValue];
        _latitude = [dict[@"latitude"] doubleValue];
    }
    return self;
}

-(void)updateWithDict:(NSDictionary *)dict{
    if (dict[@"country"])
        _country = dict[@"country"];
    if (dict[@"region"])
        _region = dict[@"region"];
    if (dict[@"city"])
        _city = dict[@"city"];
    if (dict[@"address"])
        _address = dict[@"address"];
    if (dict[@"longitude"])
        _longitude = [dict[@"longitude"] doubleValue];
    if (dict[@"latitude"])
        _latitude = [dict[@"latitude"] doubleValue];
}

-(NSDictionary *)dict{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (_country) {
        dict[@"country"] = _country;
    }
    if (_region) {
        dict[@"region"] = _region;
    }
    if (_city) {
        dict[@"city"] = _city;
    }
//    if (_latitude) {
        dict[@"latitude"] = @(_latitude);
//    }
//    if (_longitude) {
        dict[@"longitude"] = @(_longitude);
//    }
    return [dict copy];
}

@end
