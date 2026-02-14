//
//  NSString+apiVersion.h
//  Hachi
//
//  Created by Waylens Administrator on 10/14/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (apiVersion)
-(NSComparisonResult)compareWithVersion:(NSString *)version;
@end
