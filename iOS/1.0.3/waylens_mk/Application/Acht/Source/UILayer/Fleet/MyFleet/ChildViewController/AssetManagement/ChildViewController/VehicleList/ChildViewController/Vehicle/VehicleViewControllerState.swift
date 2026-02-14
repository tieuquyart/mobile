//
//  VehicleViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct VehicleViewControllerState: ReSwift.StateType, Equatable {
    public var vehicleProfile: VehicleProfile? = nil {
        didSet {
            if let vehicleProfile = vehicleProfile {
                dataSource = VehicleDataSource(items:
                    [
                        .plateNumber(vehicleProfile.plateNo),
                        .driver(vehicleProfile.name),
                        .model(vehicleProfile.type),
                        .camera(vehicleProfile.cameraSn)
                    ]
                )
            } else {
                dataSource = VehicleDataSource(items: [])
            }
        }
    }

    public private(set) var dataSource = VehicleDataSource(items: [])
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: VehicleViewState = VehicleViewState(activityIndicatingState: .none)

    public init(vehicleProfile: VehicleProfile) {
        self.vehicleProfile = vehicleProfile
        self.dataSource = VehicleDataSource(items:
            [
                .plateNumber(vehicleProfile.plateNo),
                .driver(vehicleProfile.name),
                .model(vehicleProfile.type),
                .camera(vehicleProfile.cameraSn)
            ]
        )
    }

    init() {

    }
}

public struct VehicleViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
