//
//  WLObdWorkMode.swift
//  WaylensCameraSDK
//
//  Created by forkon on 2020/12/23.
//  Copyright © 2020 Waylens. All rights reserved.
//

import WaylensFoundation

@objc
public enum WLObdWorkMode: Int {
    /// Ignition status events are triggered by Voltage and Scan OBD or J1939.
    case auto
    /// Ignition status events are triggered by Voltage only.
    case voltageOnly
    /// Ignition status events are triggered by Voltage and Scan OBD.
    case classical
    /// Ignition status events are triggered by Voltage and listen to J1939.
    case j1939Only
    /// Ignition status events are triggered by Voltage and listen to OBD. Available for there are other OBD devices plugged.
    case passive

    public func toParameterValue() -> String {
        switch self {
        case .auto:
            return "Auto"
        case .voltageOnly:
            return "VoltageOnly"
        case .classical:
            return "Classical"
        case .j1939Only:
            return "J1939Only"
        case .passive:
            return "Passive"
        }
    }
}

extension WLObdWorkMode: CaseIterable {}

@objc
public class WLObdWorkModeConfig: NSObject {
    @objc public let mode: WLObdWorkMode
    @objc public let voltageOn: Measurement<UnitElectricPotentialDifference>?
    @objc public let voltageOff: Measurement<UnitElectricPotentialDifference>?
    @objc public let voltageCheck: Measurement<UnitElectricPotentialDifference>?

    @objc public let rawData: [String : Any]

    @objc public init?(dictionary: [String : Any]) {
        guard let rawMode = dictionary[WLObdWorkModeConfigKeys.mode.rawValue] as? Int, let mode = WLObdWorkMode(rawValue: rawMode) else {
            Log.error("Failed to parse \(WLObdWorkModeConfig.classForCoder()) data: \(dictionary)!")
            return nil
        }
        self.mode = mode

        if let voltageOn = dictionary[WLObdWorkModeConfigKeys.von.rawValue] as? Int {
            self.voltageOn = Measurement(value: Double(voltageOn), unit: UnitElectricPotentialDifference.millivolts)
        }
        else {
            self.voltageOn = nil
        }

        if let voltageOff = dictionary[WLObdWorkModeConfigKeys.voff.rawValue] as? Int {
            self.voltageOff = Measurement(value: Double(voltageOff), unit: UnitElectricPotentialDifference.millivolts)
        }
        else {
            self.voltageOff = nil
        }

        if let voltageCheck = dictionary[WLObdWorkModeConfigKeys.vchk.rawValue] as? Int {
            self.voltageCheck = Measurement(value: Double(voltageCheck), unit: UnitElectricPotentialDifference.millivolts)
        }
        else {
            self.voltageCheck = nil
        }

        self.rawData = dictionary

        super.init()
    }

}

public enum WLObdWorkModeConfigKeys: String {
    case mode, von, voff, vchk
}
