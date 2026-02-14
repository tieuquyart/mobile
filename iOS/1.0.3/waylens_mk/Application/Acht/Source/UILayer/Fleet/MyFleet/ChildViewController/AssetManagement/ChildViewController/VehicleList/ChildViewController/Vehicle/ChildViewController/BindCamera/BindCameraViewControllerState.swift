//
//  BindCameraViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct BindCameraViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource = BindCameraDataSource(items: [])
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var vehicleProfile: VehicleProfile? = nil
    public var viewState: BindCameraViewState = BindCameraViewState(activityIndicatingState: .none)
    public var hasFinishedFirstLoading = false

    public init(vehicleProfile: VehicleProfile? = nil) {
        self.vehicleProfile = vehicleProfile
    }

//    public static func == (lhs: BindCameraViewControllerState, rhs: BindCameraViewControllerState) -> Bool {
//        return lhs.dataSource == rhs.dataSource &&
//            lhs.errorsToPresent == rhs.errorsToPresent &&
//            lhs.viewState == rhs.viewState
//    }
}

public struct BindCameraViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
