//
//  CameraDetail.swift
//  Fleet
//
//  Created by forkon on 2019/11/19.
//  Copyright © 2019 waylens. All rights reserved.
//

public struct CameraInfo: Codable, Equatable {
    public var cameraSN: String = ""
    public var vehiclePlateNumber: String = ""
    public let firmwareShort: String
    public let firmware: String
    public let dataUsageInKB: Int64
    public let mode: HNCameraMode?

    private enum CodingKeys: String, CodingKey {
        case firmwareShort, firmware, dataUsageInKB, mode
    }

    init(cameraSN: String, vehiclePlateNumber: String) {
        self.cameraSN = cameraSN
        self.vehiclePlateNumber = vehiclePlateNumber
        self.firmwareShort = ""
        self.firmware = ""
        self.dataUsageInKB = 0
        self.mode = nil
    }
}

