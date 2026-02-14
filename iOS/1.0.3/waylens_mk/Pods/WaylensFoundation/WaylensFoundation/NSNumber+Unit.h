//
//  NSNumber+Unit.h
//  Hachi
//
//  Created by lzhu on 4/28/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSNumber* (^NSNumberOperation)(NSNumber* number);

@interface NSNumber (Operation)
- (NSNumberOperation) add;
- (NSNumberOperation) minus;
@end

#define MEMORY_CONVERSION 1000.0f

@interface NSNumber (MemoryUnit)

- (instancetype) Bytes;     //basic unit
- (instancetype) KBytes;
- (instancetype) MBytes;
- (instancetype) GBytes;
- (instancetype) TBytes;
- (instancetype) PBytes;

- (instancetype) toBytes;
- (instancetype) toKBytes;
- (instancetype) toMBytes;
- (instancetype) toGBytes;
- (instancetype) toTBytes;
- (instancetype) toPBytes;

typedef enum MemoryUnit {
    MemoryUnitByte      =   0,
    MemoryUnitKByte     =   1,
    MemoryUnitMByte     =   2,
    MemoryUnitGByte     =   3,
    MemoryUnitTByte     =   4,
    MemoryUnitPByte     =   5,
    MemoryUnitNum       =   6
} MemoryUnit;

- (MemoryUnit) memoryUnit;

- (NSString*) memoryString;

- (NSString*) memoryStringWithMemoryUnit:(MemoryUnit)unit;

- (NSString*) memoryStringWithLeastMemoryUnit:(MemoryUnit)unit;

/*
 @(4).bytes == @(4)
 @(4).kBbytes == @(4000)
 @(4).MBytes = @(4000000)
 */
@end
