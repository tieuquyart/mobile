//
//  OtpSdk.h
//  MkOtpLibSdk
//
//  Created by VinaPay on 7/5/16.
//  Copyright © 2016 HiepPham. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @discussion The main class of SDK that contains all methods to invoke
 */
@interface eIDSdk : NSObject {
}

/*!
 * @brief To check app activated or not
 * @return true if activated else false
 */
-(bool)checkAppActivated;

- (NSString*) eIDgetDeviceName;

- (NSString*) eIDgetDeviceId;

-(bool) eIDsetAppId:(NSString*)appId;

- (void) eIDdeleteActivatedData;

- (void) eIDSetProviderSecret:(NSString*)providerSecret;


#if LOG_ENABLED
-(bool)testFunc;
#endif

@end

