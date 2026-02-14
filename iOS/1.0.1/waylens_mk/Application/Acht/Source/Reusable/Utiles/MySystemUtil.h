//
//  MySystemUtil.h
//  Vidit
//
//  Created by gliu on 14-9-22.
//  Copyright (c) 2014年 Transee Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import <UIKit/UIKit.h>

typedef void (^MyBlock)(void);

@interface MySystemUtil : NSObject
+(CGSize)ScreenSize;
+(CGFloat)ScreenWidth;
+(CGFloat)ScreenHeight;

+(NSString*)getfileMD5:(NSString*)path;
+(NSString*) getIPAddressForHostString:(NSString*)host;
//+(unsigned long)GetCRCFrom:(NSData*)data;

+(uint64_t)getFreeDiskspace;

+(NSString*) timeStringFromTimeInteval:(NSTimeInterval)time;

+ (BOOL)isSameDay:(double)time with:(double)basetime;
@end

@interface UIImage (scale)

-(UIImage*)scaleToSize:(CGSize)size;

@end


@interface myIdleTimerManager : NSObject
{
    BOOL            _bLockerDisabled;
    BOOL            _bRunning;
}
@property (strong, atomic) NSMutableArray* pTimerHandlers;
+(myIdleTimerManager*) Instance;
-(void) myIdleTimerAdd:(id)handler;
-(void) myIdleTimerRemove:(id)handler;
-(void) myIdleTimerRun:(BOOL)brun;
@end
