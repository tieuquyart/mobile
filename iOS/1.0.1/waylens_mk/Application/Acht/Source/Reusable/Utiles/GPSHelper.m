#import "GPSHelper.h"
#import <math.h>

#define LAT_OFFSET_0(x,y) -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))
#define LAT_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_2 (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_3 (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0

#define LON_OFFSET_0(x,y) 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))
#define LON_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_2 (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_3 (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0

#define RANGE_LON_MAX 137.8347
#define RANGE_LON_MIN 72.004
#define RANGE_LAT_MAX 55.8271
#define RANGE_LAT_MIN 0.8293
// jzA = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
#define jzA 6378245.0
#define jzEE 0.00669342162296594323

@implementation GPSHelper

+(BOOL) outOfChina:(CLLocationCoordinate2D)gms
{
    if (gms.longitude < 73.3 || gms.longitude > 135.17)
        return YES;
    if (gms.latitude < 3.5 || gms.latitude > 53.6)
        return YES;
    if (gms.latitude < 39.8 && gms.longitude > 124.3)//Korea & Japan
        return YES;
    if (gms.latitude < 25.4 && gms.longitude > 120.3)//Taiwan
        return YES;
    if (gms.latitude < 24 && gms.longitude > 119)//Taiwan
        return YES;
    if (gms.latitude < 21 && gms.longitude < 108.1)//SouthEastAsia
        return YES;
    if (gms.longitude < 108 && (gms.longitude + gms.latitude < 107))
        return YES;
    if (gms.latitude < 26.8 && gms.longitude < 97)//India
        return YES;
    if (gms.latitude > 10 && gms.longitude < 109) //Vietnam
        return YES;
#ifdef APPUsedByRussian
    return YES;
#endif
    return NO;
}

+(double) transformLatX:(double)x Y:(double) y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
}

+(double) transformLonX:(double)x Y:(double) y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
}

//
// World Geodetic System ==> Mars Geodetic System
+(CLLocationCoordinate2D) GMS84ToGCJ02:(CLLocationCoordinate2D)gms
{
    CLLocationCoordinate2D gcj;
    if ([self outOfChina:gms]){
        gcj.latitude = gms.latitude;
        gcj.longitude = gms.longitude;
        return gcj;
    }
    double dLat = [self transformLatX:(gms.longitude - 105.0) Y:(gms.latitude - 35.0)];
    double dLon = [self transformLonX:(gms.longitude - 105.0) Y:(gms.latitude - 35.0)];
    double radLat = gms.latitude / 180.0 * pi;
    double magic = sin(radLat);
    magic = 1 - ECee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((ECa * (1 - ECee)) / (magic * sqrtMagic) * pi);
    dLon = (dLon * 180.0) / (ECa / sqrtMagic * cos(radLat) * pi);
    gcj.latitude = gms.latitude + dLat;
    gcj.longitude = gms.longitude + dLon;
    return gcj;
}

+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location {
    return [self gcj02Decrypt:location.latitude gjLon:location.longitude];
}

+ (CLLocationCoordinate2D)gcj02Decrypt:(double)gjLat gjLon:(double)gjLon {
    CLLocationCoordinate2D  gPt = [self gcj02Encrypt:gjLat bdLon:gjLon];
    double dLon = gPt.longitude - gjLon;
    double dLat = gPt.latitude - gjLat;
    CLLocationCoordinate2D pt;
    pt.latitude = gjLat - dLat;
    pt.longitude = gjLon - dLon;
    return pt;
}

+ (CLLocationCoordinate2D)gcj02Encrypt:(double)ggLat bdLon:(double)ggLon {
    CLLocationCoordinate2D resPoint;
    double mgLat;
    double mgLon;
    if ([self outOfChina:ggLat bdLon:ggLon]) {
        resPoint.latitude = ggLat;
        resPoint.longitude = ggLon;
        return resPoint;
    }
    double dLat = [self transformLat:(ggLon - 105.0)bdLon:(ggLat - 35.0)];
    double dLon = [self transformLon:(ggLon - 105.0) bdLon:(ggLat - 35.0)];
    double radLat = ggLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - jzEE * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * M_PI);
    mgLat = ggLat + dLat;
    mgLon = ggLon + dLon;

    resPoint.latitude = mgLat;
    resPoint.longitude = mgLon;
    return resPoint;
}

+ (BOOL)outOfChina:(double)lat bdLon:(double)lon {
    if (lon < RANGE_LON_MIN || lon > RANGE_LON_MAX)
        return true;
    if (lat < RANGE_LAT_MIN || lat > RANGE_LAT_MAX)
        return true;
    return false;
}

+ (double)transformLat:(double)x bdLon:(double)y {
    double ret = LAT_OFFSET_0(x, y);
    ret += LAT_OFFSET_1;
    ret += LAT_OFFSET_2;
    ret += LAT_OFFSET_3;
    return ret;
}

+ (double)transformLon:(double)x bdLon:(double)y {
    double ret = LON_OFFSET_0(x, y);
    ret += LON_OFFSET_1;
    ret += LON_OFFSET_2;
    ret += LON_OFFSET_3;
    return ret;
}

@end
