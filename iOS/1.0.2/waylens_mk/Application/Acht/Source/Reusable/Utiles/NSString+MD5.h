//
//  NSString+MD5.h
//  MyLens
//
//  Created by gliu on 15/3/23.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)
- (NSString *)md5Encrypt;
- (NSString *)md5ASCIIEncrypt;
@end
