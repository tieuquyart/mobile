//
//  GPSHelper.h
//  Acht
//
//  Created by Chester Shen on 8/14/18.
//  Copyright © 2018 waylens. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#define ECa (6378245.0)
#define ECee (0.00669342162296594323)
#define pi (3.14159265358979324)

@interface GPSHelper: NSObject

+ (BOOL)outOfChina:(CLLocationCoordinate2D)gms;
+ (CLLocationCoordinate2D)GMS84ToGCJ02:(CLLocationCoordinate2D)gms;

/**
 *    @brief    中国国测局地理坐标（GCJ-02） 转换成 世界标准地理坐标（WGS-84）
 *
 *  ####此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 *    @param     location     中国国测局地理坐标（GCJ-02）
 *
 *    @return    世界标准地理坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location;

@end
