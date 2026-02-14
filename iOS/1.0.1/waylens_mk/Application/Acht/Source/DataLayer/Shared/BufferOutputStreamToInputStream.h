//
//  BufferWriter.m
//  Hachi
//
//  Created by Waylens Administrator on 8/26/16.
//  Copyright (c) 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BufferOutputStreamToInputStream : NSObject<NSStreamDelegate>

// you are free to set the streams delegate, you must also open and 'care' for it
// in contradiction to output stream which is encapsulated
@property (nonatomic, strong, readonly) NSInputStream * inputStream;

- (void)addDataToBuffer:(NSData *)data;
- (void)addBytesToBuffer:(const void *)bytes length:(NSUInteger)length;

// output stream will remain open until you close it manually
- (void)closeOutputStream;

// note that opening the input stream is up to you!
- (void)openOutputStream;

@end
