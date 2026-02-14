//
//  CameraProfile.swift
//  Fleet
//
//  Created by forkon on 2019/11/12.
//  Copyright © 2019 waylens. All rights reserved.
//

public struct CameraProfile: Decodable, Equatable {
    public let cameraSn: String
    public let vehicleId: String
    public let plateNumber: String
    public let driverID: String
    public let dataUsage: Int64
    public let isBind: Bool
    public var simState: SimState
    public let iccid: String
    public let hardwareModel: String
    public let firmware: String
    public let firmwareShort: String
    public let mountModel: String?
    public let mountVersion: String?

    public var isActive: Bool {
        return simState == .activated
    }

    private enum CodingKeys: String, CodingKey {
        case cameraSN
        case vehicleId
        case plateNumber
        case driverID
        case dataUsage
        case isBind
        case simState
        case iccid
        case hardwareModel = "hardwareVersion"
        case firmware
        case firmwareShort
        case mount
    }

    private enum MountCodingKeys: String, CodingKey {
        case HW
        case FW
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.cameraSn = try values.decode(String.self, forKey: .cameraSN)
        self.vehicleId = try values.decode(String.self, forKey: .vehicleId)
        self.plateNumber = try values.decode(String.self, forKey: .plateNumber)
        self.driverID = try values.decode(String.self, forKey: .driverID)
        self.dataUsage = try values.decode(Int64.self, forKey: .dataUsage)
        self.isBind = try values.decode(Bool.self, forKey: .isBind)
        self.iccid = try values.decode(String.self, forKey: .iccid)
        self.hardwareModel = try values.decode(String.self, forKey: .hardwareModel)
        self.firmware = try values.decode(String.self, forKey: .firmware)
        self.firmwareShort = try values.decode(String.self, forKey: .firmwareShort)

        if let simState = try? values.decode(SimState.self, forKey: .simState) {
            self.simState = simState
        } else {
            self.simState = .unknown
        }

        let mount = try values.nestedContainer(keyedBy: MountCodingKeys.self, forKey: .mount)
        self.mountModel = try mount.decode(String.self, forKey: MountCodingKeys.HW)
        self.mountVersion = try mount.decode(String.self, forKey: MountCodingKeys.FW)
    }
}

public enum SimState: String, Codable, Equatable {
    case activated = "ACTIVATED"
    case deactivated = "DEACTIVATED"
    case unknown = "UNKNOWN"
}
