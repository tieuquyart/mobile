//
//  AlertSettingsViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct AlertSettingsViewControllerState: ReSwift.StateType, Equatable {
    public var disabledAlertSettings: AlertSettingSet = []
    public var viewState: AlertSettingsViewState = AlertSettingsViewState(activityIndicatingState: .none)
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var hasFinishedFirstLoading = false

    public var isDrivingOrParkingAlertEnabled: Bool {
        return AlertSettings.drivingOrParking.isDisjoint(with: disabledAlertSettings)
    }

    public var isBehaviorTypeEventsAlertEnabled: Bool {
        return AlertSettings.behaviorTypeEvents.isDisjoint(with: disabledAlertSettings)
    }

    public var isHitTypeEventsAlertEnabled: Bool {
        return AlertSettings.hitTypeEvents.isDisjoint(with: disabledAlertSettings)
    }

    public var isGeoFencingTypeEventsAlertEnabled: Bool {
        return AlertSettings.geoFencingTypeEvents.isDisjoint(with: disabledAlertSettings)
    }

    init() {

    }
}

public struct AlertSettingsViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}

public typealias AlertSettingSet = Set<String>

public struct AlertSettings {
    static let drivingOrParking: AlertSettingSet = ["PARKING_MODE", "DRIVING_MODE"]
    static let behaviorTypeEvents: AlertSettingSet = AlertSettingSet(HNVideoOptions.behavior.toString().components(separatedBy: ","))
    static let hitTypeEvents: AlertSettingSet = AlertSettingSet(HNVideoOptions.hit.toString().components(separatedBy: ","))
    static let geoFencingTypeEvents: AlertSettingSet = ["GEO_FENCE_ENTER", "GEO_FENCE_EXIT"]
}
