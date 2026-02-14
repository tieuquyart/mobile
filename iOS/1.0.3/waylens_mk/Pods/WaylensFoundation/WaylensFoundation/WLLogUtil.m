//
//  WLLogUtil.m
//  Hachi
//
//  Created by Chester Shen on 4/10/17.
//  Copyright © 2017 Transee. All rights reserved.
//

#import "WLLogUtil.h"

@implementation WLLogUtil
+  (NSString *)logFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:WLLogFileName];
    return logFilePath;
}

+ (void)redirectNSlogToDocumentFolder {
    if(isatty(STDOUT_FILENO)) {//xCode
        return;
    }
    NSString *logFilePath = [self logFilePath];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSMutableString* lastlog = [[NSMutableString alloc] init];
    if ([defaultManager fileExistsAtPath:logFilePath]) {
        NSString *console = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
        if (console.length <= MaxConsoleLogSize) {
            if (console) {
                [lastlog appendString:console];
            }
        } else {
            [lastlog appendString:[console substringFromIndex:(console.length - MaxConsoleLogSize)]];
        }
    }
    [lastlog appendString:@"\n========= End of last Running ======\n\n"];
    //remove file
    [defaultManager removeItemAtPath:logFilePath error:nil];
    [lastlog writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //save Log
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

+ (NSString *)log {
    return [WLLogUtil logWithLines:-1];
}

+ (NSString *)logWithMaxLen:(NSInteger)len{
    NSString *logFilePath = [self logFilePath];
    NSString *console = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
    NSInteger startIndex = (NSInteger)console.length - len;
    return [console substringFromIndex:MAX(0, startIndex)];
}

+ (NSString*)logWithLines:(NSInteger)count {
    NSMutableString* string = [[NSMutableString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:WLLogFileName];
    NSString *console = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
    if (count > 0) {
        NSMutableArray *consoleArr = [[NSMutableArray alloc] init];
        NSRange wholeRange = NSMakeRange(0, console.length);
        NSRange range;
        do {
            range = [console rangeOfString:@"\n20" options:NSBackwardsSearch range:wholeRange];
            if (range.location < wholeRange.length) {
                NSString *substr = [console substringWithRange:NSMakeRange(range.location + 1, wholeRange.length - range.location - 1)];
                if ([substr containsString:@"FIRAnalytics"] == NO) {
                    //ignore FIRAnalytics log
                    [consoleArr addObject:substr];
                } else {
                }
                wholeRange.length = range.location + 1;
                range.location = 0;
            }
        } while (range.location < wholeRange.length);
        if (consoleArr.count == 0) {
        } else {
            NSInteger i = consoleArr.count - 1;
            if (i > count) {
                i = count;
            }
            for (; i >= 0; i--) {
                [string appendString:consoleArr[i]];
            }
        }
    } else if (console != nil) {
        [string appendString:console];
    }
    return string;
}

@end
