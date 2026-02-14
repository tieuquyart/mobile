//
//  FileUtil.h
//  WaylensFoundation
//
//  Created by forkon on 2020/8/31.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileUtil : NSObject
+(NSString *)getfileMD5:(NSString*)path;
@end

NS_ASSUME_NONNULL_END
