 //
//  ConfigSetting.h
//  testSdk
//
//  Created by TranHoangThanh on 8/25/22.
//

#import <Foundation/Foundation.h>
#import <NFaceVerificationClient/NFaceVerificationClient.h>
NS_ASSUME_NONNULL_BEGIN

@interface ConfigSetting : NSObject

- (void) setUrl:(NSString *)url;
//- (void) initFaceVerification;
- (void) finishFaceVerification;
- (void) initFaceVerification;
//- (void) initSettings;
//- (void) rearCamera;
//- (void) frontCamera;
//- (void) noneLiveness;
 
//- (void) customModeLiveness;
//- (void) passiveModeLiveness;
//- (BOOL) isFrontCamera;
//- (BOOL) isLiveness;
//- (void) manualCapturing;

//
//
//- (void) setMatching_threshold : (NInt) value;
//- (void) setQuality_threshold : (NInt) value;
//- (void) setLiveness_threshold : (NInt) value;
//
//
//- (void) setBlink_threshold : (NInt) value;
//- (void) passiveLivenessQualityThreshold : (NInt) value ;
//- (void) passiveLivenessSensitivityThreshold : (NInt) value;
//- (void) livenessBlinkTimeout : (NInt) value;



@end

NS_ASSUME_NONNULL_END
