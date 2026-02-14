//
//  SharedSDK.h
//  KeypassSDK_Shared_v1.0.0
//
//  Created by Hiep Pham on 10/22/19.
//  Copyright © 2019 Pham Hoang Hiep. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SharedSDK : NSObject

/*!
* @brief To activate app
* @param serverUrl The server url
* @param customerId The customerId...
*/
-(void)doActivateDeviceBankingWithServerUrl:(NSString*)serverUrl andCustomerId:(NSString*)customerId andProviderId:(NSString*)providerId andBranchId:(NSString*)branchId andAppId:(int)appId successHandler:(void (^)())successHandler andFailureHandler:(void (^)(NSError * _Nonnull))failureHandler;

- (void) eIDgetDeviceInfoForRegisterDevice:(NSString*)serverUrl andProviderCode:(NSString*)providerCode successHandler:(void (^)(NSString * _Nonnull))successHandler andFailureHandler:(void (^)(NSError * _Nonnull))failureHandler;

-(void)doVerifySODWithSOD:(NSString *)SOD andIDNumber:(NSString *)IDNumber andProviderCode:(NSString*)providerCode successHandler:(void (^)())successHandler andFailureHandler:(void (^)(NSError * _Nonnull))failureHandler;

-(void)createFaceTemplateWithImageInBase64:(NSString *)faceImageInBase64 andSignatureInBase64:(nonnull NSString *)signature andProviderCode:(NSString*)providerCode successHandler:(void (^)(NSString * _Nonnull))successHandler andFailureHandler:(void (^)(NSError * _Nonnull, NSString *))failureHandler;

-(void)getMocDataWithRandomData:(NSString *)randomData andFaceTemplate:(NSString *)faceTemplate andProviderCode:(NSString*)providerCode successHandler:(void (^)(NSString * _Nonnull))successHandler andFailureHandler:(void (^)(NSError * _Nonnull))failureHandler;

-(void)decryptMRZWithRandomData:(NSString *)randomData andMRZ:(NSString *)mrz andProviderCode:(NSString*)providerCode successHandler:(void (^)(NSString * _Nonnull))successHandler andFailureHandler:(void (^)(NSError * _Nonnull))failureHandler;

- (void)transactionComplete:(NSString *)bankTransactionId andBankAppId:(int)bankAppId andTransStatus:(int)transStatus andBankTransInfo:(NSString *)bankTransInfo andBankTransType:(int)bankTransType andIdNumber:(NSString *)idNumber andFullname:(NSString *)fullname andDOB:(NSString *)dob andGender:(NSString *)gender andNationality:(NSString *)nation andResidenceAddress:(NSString *)residenceAddress andPlaceOfOrigin:(NSString *)placeOfOrigin andEthnic:(NSString *)ethnic andPersonalSpecificId:(NSString *)personalSpecificId andDateOfIssue:(NSString *)dateOfIssue andDateOfExpiry:(NSString *)dateOfExpiry andSpouseName:(NSString *)spouseName andFatherName:(NSString *)fatherName andMotherName:(NSString *)motherName andOldIdNumber:(NSString *)oldIdNumber andReligion:(NSString *)religion andCustomerName:(NSString*)customerName andProviderCode:(NSString*)providerCode successHandler:(void (^)(NSString * _Nonnull))successHandler andFailureHandler:(void (^)(NSError * _Nonnull))failureHandler;

-(void)validateLicenseFVWithServerUrl:(NSString *)serverUrl andAppId:(int)appId andRegistrationKey:(NSString *)registrationKey andProviderCode:(NSString *)providerCode andBranchCode:(NSString *)branchCode successHandler:(void (^)(NSString * _Nonnull))successHandler andFailureHandler:(void (^)(NSError * _Nonnull, NSString *))failureHandler;

-(void)updateServerUrl:(NSString*)serverUrl;

-(bool)stopCurrentRequest;

@end

NS_ASSUME_NONNULL_END
