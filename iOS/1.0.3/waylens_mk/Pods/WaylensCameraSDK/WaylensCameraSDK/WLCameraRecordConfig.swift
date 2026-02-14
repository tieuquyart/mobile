//
//  WLCameraRecordConfig.swift
//  WaylensCameraSDK
//
//  Created by forkon on 2020/12/21.
//  Copyright © 2020 Waylens. All rights reserved.
//

/*
 - (instancetype)initWithDictionary:(NSDictionary *)dict {
     self = [super init];
     if (self) {
         self.minBitrateFactor = [(NSNumber *)dict[@"minBitrateFactor"] intValue];
         self.maxBitrateFactor = [(NSNumber *)dict[@"maxBitrateFactor"] intValue];
         self.recordConfig = (NSString *)dict[@"recordConfig"];
         self.bitrateFactor = [(NSNumber *)dict[@"bitrateFactor"] intValue];
         self.forceCodec = [(NSNumber *)dict[@"forceCodec"] intValue];
     }
     return self;
 }
 */

@objc
public class WLCameraRecordConfig: NSObject {
    @objc public let minBitrateFactor: Int
    @objc public let maxBitrateFactor: Int
    @objc public let recordConfig: String
    @objc public let bitrateFactor: Int
    @objc public let forceCodec: Int

    @objc public init?(dictionary: [AnyHashable : Any]) {
        guard let minBitrateFactor = dictionary["minBitrateFactor"] as? Int else {
            return nil
        }
        self.minBitrateFactor = minBitrateFactor

        guard let maxBitrateFactor = dictionary["maxBitrateFactor"] as? Int else {
            return nil
        }
        self.maxBitrateFactor = maxBitrateFactor

        guard let recordConfig = dictionary["recordConfig"] as? String else {
            return nil
        }
        self.recordConfig = recordConfig

        guard let bitrateFactor = dictionary["bitrateFactor"] as? Int else {
            return nil
        }
        self.bitrateFactor = bitrateFactor

        guard let forceCodec = dictionary["forceCodec"] as? Int else {
            return nil
        }
        self.forceCodec = forceCodec

        super.init()
    }
}
