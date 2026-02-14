//
//  GeoFenceDraftBoxViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct GeoFenceDraftBoxViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource = GeoFenceDraftBoxDataSource(items: [])
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: GeoFenceDraftBoxViewState = GeoFenceDraftBoxViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct GeoFenceDraftBoxViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
