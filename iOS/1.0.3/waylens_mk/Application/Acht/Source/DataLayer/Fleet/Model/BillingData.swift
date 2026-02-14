//
//  BillingData.swift
//  Fleet
//
//  Created by forkon on 2019/11/20.
//  Copyright © 2019 waylens. All rights reserved.
//

public struct BillingDataItem: Decodable, Equatable {
    public let cameraSN: String?
    public let iccid: String
    public let dataVolumeInMB: Double

    private enum CodingKeys: String, CodingKey {
        case cameraSN
        case iccid
        case dataVolumeInMB
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.iccid = try values.decode(String.self, forKey: .iccid)
        self.dataVolumeInMB = try values.decode(Double.self, forKey: .dataVolumeInMB)

        if values.contains(.cameraSN) {
            self.cameraSN = try values.decode(String.self, forKey: .cameraSN)
        } else {
            self.cameraSN = nil
        }
    }
}

public struct BillingData: Decodable, Equatable {
    public let cycleStartDate: Date
    public let cycleEndDate: Date
    public let totalDataVolumeInMB: Double
    public let items: [BillingDataItem]
    public let charge: Double
    public let status: String

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case cycleStartDate
        case cycleEndDate
        case totalDataVolumeInMB
        case items = "cameras"
        case charge = "totalCharge"
        case status
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let cycleStartDate = try container.decode(TimeInterval.self, forKey: .cycleStartDate)
        self.cycleStartDate = Date(millisecondsSince1970: cycleStartDate)

        let cycleEndDate = try container.decode(TimeInterval.self, forKey: .cycleEndDate)
        self.cycleEndDate = Date(millisecondsSince1970: cycleEndDate)

        let totalDataVolumeInMB = try container.decode(Double.self, forKey: .totalDataVolumeInMB)
        self.totalDataVolumeInMB = totalDataVolumeInMB

        let charge = try container.decode(Double.self, forKey: .charge)
        self.charge = charge

        let status = try container.decode(String.self, forKey: .status)
        self.status = status

        let items = try container.decode([BillingDataItem].self, forKey: .items)
        self.items = items
    }

}
