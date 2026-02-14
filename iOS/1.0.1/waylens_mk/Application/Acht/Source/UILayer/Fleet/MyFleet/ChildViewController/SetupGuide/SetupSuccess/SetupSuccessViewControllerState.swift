//
//  SetupSuccessViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct SetupSuccessViewControllerState: ReSwift.StateType, Equatable {
    public var vehicle: VehicleProfile?
    public var driver: FleetMember?
    public var camera: CameraProfile?
    public var dataSource: SetupSuccessDataSource

    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: SetupSuccessViewState = SetupSuccessViewState(activityIndicatingState: .none)

    public init(vehicle: VehicleProfile? = nil, driver: FleetMember? = nil, camera: CameraProfile? = nil) {
        self.vehicle = vehicle
        self.driver = driver
        self.camera = camera
        self.dataSource = SetupSuccessDataSource(vehicle: vehicle, driver: driver, camera: camera)
    }
}

public struct SetupSuccessViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState

//    public static func == (lhs: MemberViewState, rhs: MemberViewState) -> Bool {
//        return false
//    }
}
