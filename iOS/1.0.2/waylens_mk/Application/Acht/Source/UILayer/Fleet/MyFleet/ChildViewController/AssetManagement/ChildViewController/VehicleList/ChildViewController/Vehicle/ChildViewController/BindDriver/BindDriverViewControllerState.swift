//
//  BindDriverViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct BindDriverViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource = BindDriverDataSource(items: [])
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var vehicleProfile: VehicleProfile? = nil
    public var viewState: BindDriverViewState = BindDriverViewState(activityIndicatingState: .none)
    public var hasFinishedFirstLoading = false

    public init(vehicleProfile: VehicleProfile? = nil) {
        self.vehicleProfile = vehicleProfile
    }

}

public struct BindDriverViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
