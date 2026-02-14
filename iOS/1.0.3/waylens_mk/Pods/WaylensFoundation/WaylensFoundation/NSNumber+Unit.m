//
//  NSNumber+Unit.m
//  Hachi
//
//  Created by lzhu on 4/28/16.
//  Copyright © 2016 Transee. All rights reserved.
//

#import "NSNumber+Unit.h"

@implementation NSNumber (Operation)
- (NSNumberOperation) add {
    return ^NSNumber*(NSNumber *number) {
        if(number) {
            return @(self.doubleValue + number.doubleValue);
        } else {
            return self;
        }
    };
}
- (NSNumberOperation) minus {
    return ^NSNumber*(NSNumber *number) {
        if(number) {
            return @(self.doubleValue - number.doubleValue);
        } else {
            return self;
        }
    };
}
@end

@implementation NSNumber (MemoryUnit)

- (instancetype) Bytes {
    return self;
}
- (instancetype) KBytes {
    return @(self.doubleValue * MEMORY_CONVERSION);
}
- (instancetype) MBytes {
    return @(self.doubleValue * MEMORY_CONVERSION * MEMORY_CONVERSION);
}
- (instancetype) GBytes {
    return @(self.doubleValue * MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION);
}
- (instancetype) TBytes {
    return @(self.doubleValue * MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION);
}
- (instancetype) PBytes {
    return @(self.doubleValue * MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION);
}

- (instancetype) toBytes {
    return self;
}
- (instancetype) toKBytes {
    return @(self.doubleValue / (MEMORY_CONVERSION));
}
- (instancetype) toMBytes {
    return @(self.doubleValue / (MEMORY_CONVERSION * MEMORY_CONVERSION));
}
- (instancetype) toGBytes {
    return @(self.doubleValue / (MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION));
}
- (instancetype) toTBytes {
    return @(self.doubleValue / (MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION));
}
- (instancetype) toPBytes {
    return @(self.doubleValue / (MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION * MEMORY_CONVERSION));
}

- (MemoryUnit) memoryUnit {
    double value = self.doubleValue;
    int unit  = MemoryUnitByte;
    do {
        value /= MEMORY_CONVERSION;
        unit += 1;
    } while(value > 1.0f);
    -- unit;
    unit = MIN(MAX(0, unit), MemoryUnitNum-1);
    return (MemoryUnit)unit;
}

- (NSString*) memoryString {
    MemoryUnit unit = [self memoryUnit];
    return [self memoryStringWithMemoryUnit:unit];
}

- (NSString*) memoryStringWithLeastMemoryUnit:(MemoryUnit)leastUnit {
    MemoryUnit unit = [self memoryUnit];
    if(unit < leastUnit) {
        unit = leastUnit;
    }
    return [self memoryStringWithMemoryUnit:unit];
}

- (NSString*) memoryStringWithMemoryUnit:(MemoryUnit)unit {
    NSString *string = nil;
    switch(unit) {
        case MemoryUnitKByte: {
            string = [NSString stringWithFormat:@"%0.1f KB", self.toKBytes.doubleValue];
        } break;
        case MemoryUnitMByte: {
            string = [NSString stringWithFormat:@"%0.1f MB@", self.toMBytes.doubleValue];
        } break;
        case MemoryUnitGByte: {
            string = [NSString stringWithFormat:@"%0.1f GB", self.toGBytes.doubleValue];
        } break;
        case MemoryUnitTByte: {
            string = [NSString stringWithFormat:@"%0.1f TB", self.toTBytes.doubleValue];
        } break;
        case MemoryUnitPByte: {
            string = [NSString stringWithFormat:@"%0.1f PB", self.toPBytes.doubleValue];
        } break;
        default: {
            string = [NSString stringWithFormat:@"%0.1f Bytes", self.toBytes.doubleValue];
        } break;
    }
    return string;
}
@end
