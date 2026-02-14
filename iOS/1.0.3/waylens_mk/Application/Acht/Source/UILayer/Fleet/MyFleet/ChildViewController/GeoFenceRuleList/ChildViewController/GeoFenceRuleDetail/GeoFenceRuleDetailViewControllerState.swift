//
//  GeoFenceRuleDetailViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct GeoFenceRuleDetailViewControllerState: ReSwift.StateType, Equatable {
    public var rule: GeoFenceRule? = nil
    public var fence: GeoFence? = nil
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: GeoFenceRuleDetailViewState = GeoFenceRuleDetailViewState(activityIndicatingState: .none)

    public init(rule: GeoFenceRule? = nil) {
        self.rule = rule
    }
}

public struct GeoFenceRuleDetailViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
