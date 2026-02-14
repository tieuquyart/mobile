//
//  WLVDBVideoDownloader+FrameworkInternal.h
//  WaylensCameraSDK
//
//  Created by forkon on 2020/9/29.
//  Copyright © 2020 Waylens. All rights reserved.
//

#import <WaylensCameraSDK/WaylensCameraSDK.h>

@interface WLVDBVideoDownloader(FrameworkInternal)

-(id)initWithURL:(NSString*)url duration:(double)ms sequency:(long long)seq IOnly:(BOOL)ionly Silent:(BOOL)bSilent AudioFile:(NSString*)audioName setDelegate:(id<WLVDBVideoDownloaderDelegate>)del;

-(void)OnRemuxerEvent:(int)event para1:(int) arg1 para2:(int)arg2;

@end

