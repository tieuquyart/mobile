#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FileUtil.h"
#import "NSNumber+Unit.h"
#import "NSString+Extension.h"
#import "SSID.h"
#import "WaylensFoundation.h"
#import "WLLogUtil.h"
#import "WLTimer.h"

FOUNDATION_EXPORT double WaylensFoundationVersionNumber;
FOUNDATION_EXPORT const unsigned char WaylensFoundationVersionString[];

