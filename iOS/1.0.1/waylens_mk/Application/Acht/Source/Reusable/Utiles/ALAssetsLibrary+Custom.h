//
//  ALAssetsLibrary+Custom.h
//  TuTu
//
//  Created by gliu on 15/4/26.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import <UIKit/UIKit.h>

typedef void(^SaveImageCompletion)(NSURL*url, NSError* error);
typedef void(^SaveImageFailed)(NSError* error);
//typedef void(^findImageBlock)(UIImage* image);
//typedef void(^getALAssetRepresentationBlock)(ALAssetRepresentation* rep);

@interface ALAssetsLibrary (CustomPhotoAlbum)
-(void)saveImage:(NSData*)imagedata exif:(NSDictionary*)exif toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailedBlock:(SaveImageFailed)failedBlock;
-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailedBlock:(SaveImageFailed)failedBlock;
-(void)saveVideo:(NSURL*)mp4file toAlbum:(NSString*)albumName
withCompletionBlock:(SaveImageCompletion)completionBlock
 withFailedBlock:(SaveImageFailed)failedBlock;;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName
withCompletionBlock:(SaveImageCompletion)completionBlock
   withFailedBlock:(SaveImageFailed)failedBlock;

//-(void) findPhoto:(NSString*)url WithBlock:(findImageBlock)findBlock;
//-(void) findPhoto:(NSString*)url ThumbnailWithBlock:(findImageBlock)findBlock;

//photo or video
//-(void) getPhoto:(NSString*)url RepresentationWithBlock:(getALAssetRepresentationBlock)findBlock;
@end

