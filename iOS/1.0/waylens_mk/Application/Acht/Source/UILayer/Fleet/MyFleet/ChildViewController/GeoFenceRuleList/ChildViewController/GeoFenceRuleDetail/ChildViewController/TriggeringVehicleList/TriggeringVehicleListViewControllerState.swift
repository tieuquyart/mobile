//
//  TriggeringVehicleListViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct TriggeringVehicleListViewControllerState: ReSwift.StateType, Equatable {
    public var rule: GeoFenceRuleForEdit
    public var loadedState: LoadedState<[VehicleProfile]> = .notLoaded
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: TriggeringVehicleListViewState = TriggeringVehicleListViewState(activityIndicatingState: .none)

    public init(rule: GeoFenceRuleForEdit = GeoFenceRuleForEdit()) {
        self.rule = rule
    }
}

public struct TriggeringVehicleListViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
