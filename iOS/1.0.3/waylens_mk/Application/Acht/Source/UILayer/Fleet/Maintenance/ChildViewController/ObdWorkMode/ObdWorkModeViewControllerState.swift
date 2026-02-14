//
//  ObdWorkModeViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift
import WaylensCameraSDK

public struct ObdWorkModeViewControllerState: ReSwift.StateType, Equatable {
    public var items: [WLObdWorkMode] = WLObdWorkMode.allCases
    public var config: WLObdWorkModeConfig? = nil
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: ObdWorkModeViewState = ObdWorkModeViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct ObdWorkModeViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState

//    public static func == (lhs: MemberViewState, rhs: MemberViewState) -> Bool {
//        return false
//    }
}

extension WLObdWorkMode {

    public var name: String {
        switch self {
        case .auto:
            return NSLocalizedString("Auto", comment: "Auto")
        case .voltageOnly:
            return NSLocalizedString("Voltage Only", comment: "Voltage Only")
        case .classical:
            return NSLocalizedString("Classical", comment: "Classical")
        case .j1939Only:
            return NSLocalizedString("J1939 Only", comment: "J1939 Only")
        case .passive:
            return NSLocalizedString("Passive", comment: "Passive")
        @unknown default:
            return ""
        }
    }

    public var description: String {
        switch self {
        case .auto:
            return NSLocalizedString("Ignition status events are triggered by Voltage and Scan OBD or J1939.", comment: "Ignition status events are triggered by Voltage and Scan OBD or J1939.")
        case .voltageOnly:
            return NSLocalizedString("Ignition status events are triggered by Voltage only.", comment: "Ignition status events are triggered by Voltage only.")
        case .classical:
            return NSLocalizedString("Ignition status events are triggered by Voltage and Scan OBD.", comment: "Ignition status events are triggered by Voltage and Scan OBD.")
        case .j1939Only:
            return NSLocalizedString("Ignition status events are triggered by Voltage and listen to J1939.", comment: "Ignition status events are triggered by Voltage and listen to J1939.")
        case .passive:
            return NSLocalizedString("Ignition status events are triggered by Voltage and listen to OBD. Available for there are other OBD devices plugged.", comment: "Ignition status events are triggered by Voltage and listen to OBD. Available for there are other OBD devices plugged.")
        @unknown default:
            return ""
        }
    }

}
