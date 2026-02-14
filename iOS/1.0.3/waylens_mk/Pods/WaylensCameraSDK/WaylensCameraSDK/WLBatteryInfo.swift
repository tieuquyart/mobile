//
//  WLBatteryInfo.swift
//  WaylensCameraSDK
//
//  Created by forkon on 2020/12/16.
//  Copyright © 2020 Waylens. All rights reserved.
//

import Foundation

@objc
public class WLBatteryInfo: NSObject {
    @objc public let capacityLevel: String?
    @objc public let capacityPercent: Int
    @objc public let status: String?
    @objc public let isOnline: Bool
    @objc public let currentVoltage: Measurement<UnitElectricPotentialDifference>

    @objc public init(dictionary: [String : Any]) {
        self.capacityLevel = dictionary[WLBatteryInfoKeys.capacityLevel.rawValue] as? String
        self.capacityPercent = (dictionary[WLBatteryInfoKeys.capacity.rawValue] as? Int) ?? 0
        self.status = dictionary[WLBatteryInfoKeys.status.rawValue] as? String
        self.isOnline = (dictionary[WLBatteryInfoKeys.online.rawValue] as? Int) == 1 ? true : false
        self.currentVoltage = Measurement(value: Double((dictionary[WLBatteryInfoKeys.voltageNow.rawValue] as? String) ?? "0") ?? 0, unit: UnitElectricPotentialDifference.millivolts)
        
        super.init()
    }
}

enum WLBatteryInfoKeys: String {
    case capacityLevel = "temp.power_supply.capacity_level"
    case capacity = "temp.power_supply.capacity"
    case status = "temp.power_supply.status"
    case online = "temp.power_supply.online"
    case voltageNow = "temp.power_supply.voltage_now"
}
