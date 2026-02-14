//
//  ALAssetsLibrary+Custom.m
//  TuTu
//
//  Created by gliu on 15/4/26.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ALAssetsLibrary+Custom.h"


@implementation ALAssetsLibrary(CustomPhotoAlbum)

-(void)saveImage:(NSData*)imagedata exif:(NSDictionary*)exif toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailedBlock:(SaveImageFailed)failedBlock
{
    [self writeImageDataToSavedPhotosAlbum:imagedata metadata:exif completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error!=nil){
            failedBlock(error);
            return;
        } else {
            completionBlock(assetURL, nil);
        }
        if (albumName != nil) {
            [self addAssetURL:assetURL
                      toAlbum:albumName
          withCompletionBlock:completionBlock
              withFailedBlock:failedBlock];
        }
    }];
    return;
}
-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailedBlock:(SaveImageFailed)failedBlock
{
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
                                                                (__bridge CMAttachmentBearerRef)(image),
                                                                kCMAttachmentMode_ShouldPropagate);
    [self writeImageDataToSavedPhotosAlbum:UIImageJPEGRepresentation(image, 0.85)
                                  metadata:(__bridge id)attachments
                           completionBlock:^(NSURL* assetURL, NSError* error) {
                               //error handling
                               if (error!=nil) {
                                   failedBlock(error);
                                   return;
                               } else {
                                   if (albumName != nil) {
                                       [self addAssetURL:assetURL
                                                 toAlbum:albumName
                                     withCompletionBlock:completionBlock
                                         withFailedBlock:failedBlock];
                                   }
                               }
                           }
     ];
    attachments = nil;
    return;
}
-(void) saveVideo:(NSURL*)mp4file toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailedBlock:(SaveImageFailed)failedBlock
{
    //write the video data to the assets library (camera roll)
    [self writeVideoAtPathToSavedPhotosAlbum:mp4file
                             completionBlock:^(NSURL* assetURL, NSError* error) {
                                 //error handling
                                 if (error!=nil){
                                     failedBlock(error);
                                     return;
                                 } else if (albumName != nil) {
                                     //add the asset to the custom photo album
                                     [self addAssetURL:assetURL
                                               toAlbum:albumName
                                   withCompletionBlock:completionBlock
                                       withFailedBlock:failedBlock];
                                 } else {
                                     completionBlock(assetURL, nil);
                                 }
                             }];
}
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailedBlock:(SaveImageFailed)failedBlock
{
    NSLog(@"URL %@", [assetURL absoluteString]);
    __block BOOL albumWasFound = NO;
    //search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            if (albumName != nil && [albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                //target album is found
                                albumWasFound = YES;
                                //get a hold of the photo's asset instance
                                [self assetForURL: assetURL
                                      resultBlock:^(ALAsset *asset){
                                          //add photo to the target album
                                          [group addAsset: asset];
                                          //run the completion block
                                          completionBlock(assetURL, nil);
                                      }
                                     failureBlock: failedBlock];
                                //album was found, bail out of the method
                                return;
                            }
                            if (group==nil && albumWasFound==NO) {
                                //photo albums are over, target album does not exist, thus create it
                                ALAssetsLibrary* weakSelf = self;
                                //create new assets album
                                [self addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                                    //get the photo's instance
                                    [weakSelf assetForURL: assetURL
                                              resultBlock:^(ALAsset *asset) {
                                                  //add photo to the newly created album
                                                  [group addAsset: asset];
                                                  //call the completion block
                                                  completionBlock(assetURL, nil);
                                              } failureBlock: failedBlock];
                                } failureBlock: failedBlock];
                                //should be the last iteration anyway, but just in case
                                return;
                            }
                        }
                      failureBlock: failedBlock];
}

//-(void) findPhoto:(NSString*)url WithBlock:(findImageBlock)findBlock
//{
//    [self getPhoto:url RepresentationWithBlock:^(ALAssetRepresentation *rep) {
//        if (rep == nil) {
//            findBlock(nil);
//        } else {
//            void* buf = malloc((size_t)[rep size]);
//            [rep getBytes:buf fromOffset:0 length:(NSUInteger)[rep size] error:nil];
//            findBlock([UIImage imageWithData:[NSData dataWithBytes:buf length:(NSUInteger)[rep size]]]);
//            free(buf);
//        }
//    }];
//}
//
//-(void) findPhoto:(NSString*)url ThumbnailWithBlock:(findImageBlock)findBlock
//{
//    if (url == nil || [url isEqualToString:@""]) {
//        findBlock(nil);
//        return;
//    }
//    [self assetForURL:[NSURL URLWithString:url] resultBlock:^(ALAsset *asset) {
//        NSString* assetType = [asset valueForProperty:ALAssetPropertyType];
//        if([assetType isEqualToString:ALAssetTypePhoto]) {
//            BOOL returned = NO;
//            NSDictionary *assetUrls = [asset valueForProperty:ALAssetPropertyURLs];
//            for (NSString *assetURLKey in assetUrls) {
//                if ([[[assetUrls objectForKey:assetURLKey] absoluteString] isEqualToString:url]) {
//                    findBlock([UIImage imageWithCGImage:asset.thumbnail]);
//                    returned = YES;
//                    break;
//                }
//            }
//            if (returned == NO) {
//                findBlock(nil);
//                NSLog(@"NOT find %@", url);
//            }
//        } else {
//            findBlock(nil);
//            NSLog(@"NOT find %@", url);
//        }
//    } failureBlock:^(NSError *error) {
//        findBlock(nil);
//        NSLog(@"NOT find %@", url);
//    }];
//}
//
//-(void) getPhoto:(NSString*)url RepresentationWithBlock:(getALAssetRepresentationBlock)findBlock
//{
//    if (url == nil || [url isEqualToString:@""]) {
//        findBlock(nil);
//        return;
//    }
//    [self assetForURL:[NSURL URLWithString:url] resultBlock:^(ALAsset *asset) {
//        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
//        findBlock(assetRep);
//    } failureBlock:^(NSError *error) {
//        findBlock(nil);
//    }];
//}

@end
