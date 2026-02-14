//
//  NSString+Extension.m
//  Hachi
//
//  Created by lzhu on 3/9/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

+ (BOOL) isNullOrEmpty:(NSString*)string {
     return (string == nil) || ([@"" isEqualToString:string]);
}

-(WLStringFormatError) matchWithFormat:(WLStringFormat *)format {
    return [format matchString:self];
}

- (BOOL) isValidForFormat:(WLStringFormat*)format {
    return [format matchString:self] == WLStringNoneError;
}

@end

NSString* NSStringFromNSIndexPath(NSIndexPath *indexPath) {
    NSMutableString *string = [NSMutableString stringWithString:@"NSIndexPath("];
    for (NSUInteger index = 0; index < indexPath.length; ++index) {
        [string appendString:@([indexPath indexAtPosition:index]).stringValue];
        if(index + 1 == indexPath.length) {
            [string appendString:@")"];
        } else {
            [string appendString:@", "];
        }
    }
    return [string copy];
}

void logObject(NSObject *object) {
    NSLog(@"%@", object);
}


static WLStringFormatError matchStringForFormat(NSString *string, NSString *format, NSUInteger minLength, NSUInteger maxLength) {
    if((string == nil) || [@"" isEqualToString:string]) {
        return WLStringEmptyError;
    }
    if(([string length] < minLength) || ([string length] > maxLength)) {
        return WLStringLengthError;
    }
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:format options:NSRegularExpressionUseUnixLineSeparators error:&error];
    if(error) {
        assert(0);
    }
    NSTextCheckingResult *result = [regex firstMatchInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    NSRange range = result.range;
    if((range.location == 0) && (range.length == string.length)) {
        return WLStringNoneError;
    } else {
        return WLStringMatchError;
    }
}

NSString * const kNSRegularExpressionEmail = @"^([a-zA-Z0-9_\\.-])+@(([a-zA-Z0-9])+\\.)+([a-zA-Z0-9]{2,4})+$";
NSString * const kNSRegularExpressionPhoneNumberInChina = @"^1[0-9]{10}$";
NSString * const kNSRegularExpressionVerifyingCode = @"^[0-9]{6}$";
NSString * const kNSRegularExpressionPassword = @"^[0-9A-Za-z_]{6,}$";
NSString * const kNSRegularExpressionUserName = @"[A-Za-z0-9_]{1,32}";

@interface WLEmailFormat : WLStringFormat
@end @implementation WLEmailFormat
- (WLStringFormatError) matchString:(NSString *)string {
    return matchStringForFormat(string, kNSRegularExpressionEmail, 0, 2000);
}
@end

@interface WLUsernameFormat : WLStringFormat
@end @implementation WLUsernameFormat
- (WLStringFormatError) matchString:(NSString *)string {
    return matchStringForFormat(string, kNSRegularExpressionUserName, 0, 2000);
}
@end

@interface WLPhoneFormat : WLStringFormat
@end @implementation WLPhoneFormat
- (WLStringFormatError) matchString:(NSString *)string {
    return matchStringForFormat(string, kNSRegularExpressionPhoneNumberInChina, 0, 2000);
}
@end

@interface WLLengthFormat : WLStringFormat
@property (assign, nonatomic) NSRange lengthRange;
@end @implementation WLLengthFormat
- (WLStringFormatError) matchString:(NSString *)string {
    if(string.length >= _lengthRange.location && string.length <= _lengthRange.location + _lengthRange.length) {
        return WLStringNoneError;
    } else {
        return WLStringLengthError;
    }
}
@end

@interface WLDigitsFormat : WLStringFormat
@property (assign, nonatomic) NSRange lengthRange;
@end @implementation WLDigitsFormat
- (WLStringFormatError) matchString:(NSString *)string {
    NSString *regex = nil;
    if(_lengthRange.length != 0) {
        regex = [NSString stringWithFormat:@"^[0-9]{%@, %@}$", @(_lengthRange.location), @(_lengthRange.location + _lengthRange.length)];
    } else {
        regex = [NSString stringWithFormat:@"^[0-9]{%@}$", @(_lengthRange.location)];
    }
    return matchStringForFormat(string, regex, _lengthRange.location, _lengthRange.length + _lengthRange.location);
}
@end

@interface WLMultiFormat : WLStringFormat
@property (strong, nonatomic) NSArray *formats;
@end @implementation WLMultiFormat
- (WLStringFormatError) matchString:(NSString *)string {
    assert(_formats != nil && _formats.count != 0);
    for (WLStringFormat *format in _formats) {
        WLStringFormatError error = [format matchString:string];
        if(error != WLStringNoneError) {
            return error;
        }
    }
    return WLStringNoneError;
}
@end

@interface WLEqualFormat : WLStringFormat
@property (assign, nonatomic) NSString *baseString;
@end @implementation WLEqualFormat
- (WLStringFormatError) matchString:(NSString *)string {
    return matchStringForFormat(string, _baseString, _baseString.length, _baseString.length);
}
@end



@implementation WLStringFormat

- (WLStringFormatError) matchString:(NSString*)string {
    return WLStringNoneError;
}

+ (instancetype) emailFormat {
    return [[WLEmailFormat alloc] init];
}

+ (instancetype) usernameFormat {
    return [[WLUsernameFormat alloc] init];
}

+ (instancetype) phoneFormat {
    return [[WLPhoneFormat alloc] init];
}

+ (instancetype) lengthFormatWithRange:(NSRange)range {
    WLLengthFormat *format = [[WLLengthFormat alloc] init];
    format.lengthRange = range;
    return format;
}

+ (instancetype) digitsFormatWithLengthRange:(NSRange)range {
    WLDigitsFormat *format = [[WLDigitsFormat alloc] init];
    format.lengthRange = range;
    return format;
}

+ (instancetype) formatWithformats:(NSArray<WLStringFormat *> *)formats {
    WLMultiFormat *format = [[WLMultiFormat alloc] init];
    format.formats = formats;
    return format;
}

+ (instancetype) formatWithString:(NSString*)string {
    WLEqualFormat *format = [[WLEqualFormat alloc] init];
    format.baseString = string;
    return format;
}

@end
