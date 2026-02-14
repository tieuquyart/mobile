//
//  GeoFenceRuleListViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct GeoFenceRuleListViewControllerState: ReSwift.StateType, Equatable {
    public var loadedState: LoadedState<[GeoFenceRule]> = .notLoaded
    public var hasDrafts = true
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: GeoFenceRuleListViewState = GeoFenceRuleListViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct GeoFenceRuleListViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
