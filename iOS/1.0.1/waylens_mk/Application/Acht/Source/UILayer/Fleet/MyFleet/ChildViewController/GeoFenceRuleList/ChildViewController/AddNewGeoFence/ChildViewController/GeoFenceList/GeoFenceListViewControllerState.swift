//
//  GeoFenceListViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct GeoFenceListViewControllerState: ReSwift.StateType, Equatable {
    public var rule: GeoFenceRuleForEdit
    public var loadedState: LoadedState<[GeoFenceListItem]> = .notLoaded
    public var type: GeoFenceListType = .all
    public var loadingGeoFences: Set<GeoFenceId> = []
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: GeoFenceListViewState = GeoFenceListViewState(activityIndicatingState: .none)

    public init(rule: GeoFenceRuleForEdit? = nil, type: GeoFenceListType = .all) {
        if let rule = rule {
            self.rule = rule
        }
        else {
            self.rule = GeoFenceRuleForEdit()
        }
        
        self.type = type
    }
}

public struct GeoFenceListViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
