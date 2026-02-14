//
//  WLLogUtil.h
//  Hachi
//
//  Created by Chester Shen on 4/10/17.
//  Copyright © 2017 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
#define WLLogFileName @"ConcoleLog.txt"
#define MaxConcoleLogLines 5000
#define MaxConsoleLogSize 1000000
#define WLScreenShotFolderName @"screenshot"
@interface WLLogUtil : NSObject
+  (NSString *)logFilePath;
+ (void)redirectNSlogToDocumentFolder;
+ (NSString*)log;
+ (NSString *)logWithMaxLen:(NSInteger)len;
+ (NSString*)logWithLines:(NSInteger)count;
@end
