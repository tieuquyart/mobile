//
//  NSString+EmailDomain.m
//  Hachi
//
//  Created by gliu on 6/8/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSString+EmailDomain.h"

@implementation NSString (EmailDomain)

+ (NSString*)emailDomainWithSuffix:(NSString*)suffix {
    if ([[suffix lowercaseString] isEqualToString:@"gmail.com"]) {
        return @"https://mail.google.com/mail";
    }
    return nil;
}
@end
