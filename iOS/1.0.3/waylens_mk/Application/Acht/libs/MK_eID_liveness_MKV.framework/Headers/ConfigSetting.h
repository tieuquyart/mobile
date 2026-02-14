 //
//  ConfigSetting.h
//  testSdk
//
//  Created by TranHoangThanh on 8/25/22.
//

#import <Foundation/Foundation.h>
#import <NFaceVerificationClient/NFaceVerificationClient.h>


@interface ConfigSetting : NSObject


- (NSString *)getUrlLiveness;
- (void) setUrl:(NSString *)url;
- (void) finishFaceVerification;
- (void) initFaceVerification;


- (void) noneLiveness;
- (void) passiveModeLiveness;
- (void) customModeLiveness;

@end

