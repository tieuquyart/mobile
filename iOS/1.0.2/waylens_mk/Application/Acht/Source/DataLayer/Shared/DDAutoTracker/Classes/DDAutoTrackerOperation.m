//
//  DDAutoTrackerOperation.m
//  DDAutoTracker
//
//  Created by 王海亮 on 2017/12/18.
//

#import "DDAutoTrackerOperation.h"
#import "DDAutoTrackerManager.h"
#import "NSObject+DDAutoTracker.h"

@implementation DDAutoTrackerOperation

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

/**
 发送日志
 
 @param eventId 日志id
 @param info 日志内容
 */
- (void)sendTrackerData:(NSString *)eventId info:(NSDictionary *)info {
    NSDictionary *trackerDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       eventId.length > 0 ? eventId : @"", DDAutoTrackerEventIDKey,
                                       info, DDAutoTrackerInfoKey, nil];
    
    if ([DDAutoTrackerManager sharedInstance].successBlock && [DDAutoTrackerManager sharedInstance].configArray.count > 0 &&
        eventId.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(key == %@)",eventId];
        NSArray *filtered = [[DDAutoTrackerManager sharedInstance].configArray filteredArrayUsingPredicate:predicate];
        NSDictionary *config = filtered.firstObject;
        if (config != nil) {
            if (!config[@"disabled"]) {
                NSMutableDictionary *dict = [trackerDictionary mutableCopy];
                dict[DDAutoTrackerNameKey] = [filtered.firstObject objectForKey:@"name"];
                [DDAutoTrackerManager sharedInstance].successBlock(dict);
            }
        } else {
            [DDAutoTrackerManager sharedInstance].successBlock(trackerDictionary);
        }
    }
    
    if ([DDAutoTrackerManager sharedInstance].isDebug &&
        [DDAutoTrackerManager sharedInstance].debugBlock) {
        [DDAutoTrackerManager sharedInstance].debugBlock(trackerDictionary);
    }
}

@end

