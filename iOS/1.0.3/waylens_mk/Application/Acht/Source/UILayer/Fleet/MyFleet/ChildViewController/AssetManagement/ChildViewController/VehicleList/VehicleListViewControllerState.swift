//
//  VehicleListViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct VehicleListViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource = VehicleListDataSource(vehicles: [])
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: VehicleListViewState = VehicleListViewState(activityIndicatingState: .none)
    public var hasFinishedFirstLoading = false

    public init() {

    }

}

public struct VehicleListViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
