//
//  NSDate+Format.h
//  Hachi
//
//  Created by lzhu on 3/2/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const NSDateFormatYMDHMS;
FOUNDATION_EXTERN NSString * const NSDateFormatYMDHM;
FOUNDATION_EXTERN NSString * const NSDateFormatMDHM;
FOUNDATION_EXTERN NSString * const NSDateFormatHMS;
FOUNDATION_EXTERN NSString * const NSDateFormatYMD;
FOUNDATION_EXTERN NSString * const NSDateFormatSVG;
FOUNDATION_EXTERN NSString * const NSDateFormatUSDateTime;
FOUNDATION_EXTERN NSString * const NSDateFormatUSTime;
FOUNDATION_EXTERN NSString * const NSDateFormatTimeHMA;

@interface NSDate (Format)

+ (NSDate*) dateFromString:(NSString*)dateString withFormat:(NSString*)format;

+ (NSDateFormatter*) dateFormatterWithFormat:(NSString*)format;

- (NSString*) dateStringWithFormat:(NSString*)format;

- (NSString*) dateStringWithFormat:(NSString *)format refrenceNow:(BOOL)refrence;

- (NSString*) socialTimestamp;
- (NSString *)videoTimestamp;
+ (double) zoneInterval;
+ (NSString *)currentGMTDateString;
@end
