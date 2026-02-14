//
//  myGetSHA1.h
//  MyLens
//
//  Created by gliu on 15/3/24.
//  Copyright (c) 2015年 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface myGetSHA1 : NSObject

+(NSString*) getSHA1ValueFromData:(NSData*)data ToBuffer:(char*)buffer;
+(NSString*) getSHA1ValueFromFile:(NSString*)path ToBuffer:(char*)buffer;
//+(NSString*) getSHA1ValueFromAsset:(ALAssetRepresentation*)assetRepresentation ToBuffer:(char*)buffer;
@end
