//
//  NSString+EmailDomain.h
//  Hachi
//
//  Created by gliu on 6/8/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EmailDomain)

+ (NSString*)emailDomainWithSuffix:(NSString*)suffix;

@end
