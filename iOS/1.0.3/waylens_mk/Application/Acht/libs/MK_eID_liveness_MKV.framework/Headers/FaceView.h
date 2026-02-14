
#import <UIKit/UIKit.h>
#import <NFaceVerificationClient/NFaceVerificationClient.h>
//@class EIDSDK;


/**
Callback block that is called when a recording session is complete.
**/
typedef void(^GlimpseCompletedCallback)(NSURL *fileOuputURL);


@protocol FaceViewDelegate <NSObject>
- (void)showStatus:(NSString*)value;
- (void)validateLicense:(NSError *)error withMessage:(NSString*)value;
- (void)fileVideoOutputPath:(NSURL*)moviePath withImage1:(UIImage *)image1 withImage2:(UIImage *)image2;
- (void)getTemplateSuccess;

@end

@interface  FaceView : UIView

@property (weak, nonatomic) id<FaceViewDelegate> delegate;
- (void)enrollTask;
- (void)startExtractFace;
- (void)cancelOperationTask;

@end

