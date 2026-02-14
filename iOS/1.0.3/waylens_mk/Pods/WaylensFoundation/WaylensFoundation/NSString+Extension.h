//
//  NSString+Extension.h
//  Hachi
//
//  Created by lzhu on 3/9/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLStringFormat;

typedef enum WLStringFormatError {
    WLStringNoneError,
    WLStringEmptyError,
    WLStringLengthError,
    WLStringMatchError
} WLStringFormatError;

@interface NSString (Extension)

+ (BOOL) isNullOrEmpty:(NSString*)string;

- (WLStringFormatError) matchWithFormat:(WLStringFormat*)format;
- (BOOL) isValidForFormat:(WLStringFormat*)format;

@end

FOUNDATION_EXTERN NSString* NSStringFromNSIndexPath(NSIndexPath *indexPath);

FOUNDATION_EXTERN void logObject(NSObject *object);


@interface WLStringFormat : NSObject

- (WLStringFormatError) matchString:(NSString*)string;

+ (instancetype) emailFormat;

+ (instancetype) usernameFormat;

+ (instancetype) phoneFormat;

+ (instancetype) lengthFormatWithRange:(NSRange)range;

+ (instancetype) digitsFormatWithLengthRange:(NSRange)range;

+ (instancetype) formatWithformats:(NSArray<WLStringFormat*>*)formats;

+ (instancetype) formatWithString:(NSString*)string;

@end