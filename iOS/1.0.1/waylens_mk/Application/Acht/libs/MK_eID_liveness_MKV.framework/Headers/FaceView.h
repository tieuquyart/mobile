
#import <UIKit/UIKit.h>
#import <NFaceVerificationClient/NFaceVerificationClient.h>
//@class EIDSDK;
NS_ASSUME_NONNULL_BEGIN


@protocol FaceViewDelegate <NSObject>
- (void)showStatus:(NSString*)value;
//- (void)getImage :(UIImageView*)image;
- (void)getTemplateSuccess;

@end


@interface  FaceView : UIView

@property (weak, nonatomic) id<FaceViewDelegate> delegate;
- (void)setFaceImage:(UIImage*)image;

- (void)setCurrentYaw:(NFloat)yaw;
- (void)setCurrentRoll:(NFloat)roll;
- (void)setFaceBoundingRect:(CGRect)rect;
- (void)setLivenessAction:(NfvcLivenessAction)action;
- (void)setLivenessTargetYaw:(NFloat)yaw;
- (void)setLivenessScore:(NByte)score;
- (void)setIcaoWarnings:(NfvcIcaoWarnings)icaoWarnings;
- (void)clearFaceBoundingRect;
- (void)repaintOverlay;
- (void)clearOverlay;
//- (void)enrollTaskWithServerUrl:(NSString *)serverUrl andBranchCode:(NSString *)branchCode;
- (void)enrollTask:(void (^)(NSError * _Nonnull, NSString *))failureHandler;
- (void)startExtractFace;
- (void)cancelOperationTask;

@end
NS_ASSUME_NONNULL_END
