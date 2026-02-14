//
//  AddNewVehicleViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct AddNewVehicleViewControllerState: ReSwift.StateType, Equatable {
    public var vehicleProfile: VehicleProfile = VehicleProfile.emptyProfile
    public var selectedDriver: FleetMember? = nil
    public var selectedCamera: CameraProfile? = nil
    public var cameras: [CameraProfile] = []

    public var hasBoundDriver: Bool = false
    public var hasBoundCamera: Bool = false
    public var bindDriverFailed: Bool = false
    public var bindCameraFailed: Bool = false

    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: AddNewVehicleViewState = AddNewVehicleViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct AddNewVehicleViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
