//
//  NSDate+Format.m
//  Hachi
//
//  Created by lzhu on 3/2/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSDate+Format.h"

#define tr(key) NSLocalizedString(key, nil)

NSString * const NSDateFormatYMDHMS    =   @"yyyy-MM-dd HH:mm:ss";
NSString * const NSDateFormatYMDHM     =   @"yyyy-MM-dd HH:mm";
NSString * const NSDateFormatMDHM      =   @"MM-dd HH:mm";
NSString * const NSDateFormatHMS       =   @"HH:mm:ss";
NSString * const NSDateFormatYMD       =   @"yyyy-MM-dd";
NSString * const NSDateFormatSVG        =   @"MM dd, yyyy HH:mm:ss";
NSString * const NSDateFormatUSDateTime         =   @"MM/dd/yyyy hh:mm:ss a";
NSString * const NSDateFormatUSTime         =   @"hh:mm:ss a";
NSString * const NSDateFormatTimeHMA = @"h:mm a";
NSString * const NSDateFormatHTTP = @"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz";

@implementation NSDate (Format)

+ (NSDateFormatter*) dateFormatterWithFormat:(NSString*)format {
    static NSMutableDictionary *formatters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatters = [NSMutableDictionary dictionary];
        NSArray *formats = @[NSDateFormatYMDHMS, NSDateFormatYMDHM, NSDateFormatHMS,NSDateFormatYMD, NSDateFormatMDHM, NSDateFormatSVG, NSDateFormatUSDateTime, NSDateFormatUSTime, NSDateFormatTimeHMA];
        for(NSString *fmt in formats) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = tr(fmt);
            formatter.locale = [NSLocale currentLocale];
            formatter.timeZone = [NSTimeZone localTimeZone];
            [formatters setObject:formatter forKey:fmt];
        }
    });
    return [formatters objectForKey:format];
}

+ (NSDate*) dateFromString:(NSString*)dateString withFormat:(NSString*)format {
    NSDateFormatter *formatter = [self dateFormatterWithFormat:format];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

- (NSString*) dateStringWithFormat:(NSString*)format {
    NSDateFormatter *formatter = [NSDate dateFormatterWithFormat:format];
    NSString *dateString = [formatter stringFromDate:self];
    return dateString;
}

- (NSString*) dateStringWithFormat:(NSString *)format refrenceNow:(BOOL)refrence {
    if(!refrence) {
        return [self dateStringWithFormat:format];
    }
    NSDate *now = [NSDate date];
    NSTimeInterval interval1 = [self timeIntervalSince1970];
    NSTimeInterval interval2 = [now timeIntervalSince1970];
    NSTimeInterval timeInterval = interval2 - interval1;
    if(timeInterval < 0) {
        return tr(@"Now");
    }
    if(timeInterval < 60) {
        return [NSString stringWithFormat:@"%d %@", (int)timeInterval,  tr(@"Seconds Ago")];
    } else if(timeInterval < 60 * 60) {
        return [NSString stringWithFormat:@"%d %@", (int)(timeInterval/60), tr(@"Minutes Ago")];
    } else if(timeInterval < 12 * 60 * 60) {
        return [NSString stringWithFormat:@"%d %@", (int)(timeInterval/(60*60)), tr(@"Hours Ago")];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeInterval secondsInOneDay = (24 * 60 * 60);
    NSDateComponents *c2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    NSDate *today = [calendar dateFromComponents:c2];
    NSTimeInterval interval3 = [today timeIntervalSince1970];
    NSString *dateString = [self dateStringWithFormat:NSDateFormatHMS];
    if(interval1 >= interval3) {
        return [NSString stringWithFormat:@"%@ %@", tr(@"Today"), dateString];
    } else if(interval1 + secondsInOneDay >= interval3) {
        return [NSString stringWithFormat:@"%@ %@", tr(@"Yesterday"), dateString];
    } else {
        return [self dateStringWithFormat:format];
    }
}

- (NSString *)videoTimestamp {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *c1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    NSDateComponents *c2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    if (c1.year == c2.year && c1.month == c2.month && c1.day == c2.day) {
        return [self dateStringWithFormat:NSDateFormatUSTime];
    } else {
        return [self dateStringWithFormat:NSDateFormatUSDateTime];
    }
}

- (NSString*) socialTimestamp {
    NSDate *now = [NSDate date];
    NSTimeInterval nowInterval = now.timeIntervalSince1970;
    NSTimeInterval selfInterval= self.timeIntervalSince1970;
    NSTimeInterval diff = nowInterval - selfInterval;
    if(diff < 10.0f) {
        return tr(@"Now");
    } else if(diff < 60) {
        return [NSString stringWithFormat:@"%@%@",@((long)diff), tr(@"s")];
    } else if(diff < 60 * 60) {
        return [NSString stringWithFormat:@"%@%@",@((long)diff/60), tr(@"m")];
    } else if(diff < 24 * 60 * 60) {
        return [NSString stringWithFormat:@"%@%@",@((long)diff/(60*60)), tr(@"h")];
    } else if(diff < 7 * 24 * 60 * 60) {
        return [NSString stringWithFormat:@"%@%@",@((long)diff/(24 * 60 * 60)), tr(@"d")];
    } else {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *c1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
        NSDateComponents *c2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
        if(c1.year == c2.year) {
            return [NSString stringWithFormat:@"%@/%@", @(c2.month), @(c2.day)];
        } else {
            return [NSString stringWithFormat:@"%@/%@,%@", @(c2.month), @(c2.day), @(c2.year)];
        }
    }
}

+ (double) zoneInterval {
    NSDate *now = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: now];
    return interval;
}

+ (NSString *)currentGMTDateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = NSDateFormatHTTP;
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    return [dateFormatter stringFromDate:[NSDate date]];
}
@end
