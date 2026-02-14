//
//  VehicleSelectorViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct VehicleSelectorViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource = VehicleSelectorDataSource(items: [])
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var vehicleProfile: VehicleProfile? = nil
    public var viewState: VehicleSelectorViewState = VehicleSelectorViewState(activityIndicatingState: .none)
    public var hasFinishedFirstLoading = false

    public init(vehicleProfile: VehicleProfile? = nil) {
        self.vehicleProfile = vehicleProfile
    }

}

public struct VehicleSelectorViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
