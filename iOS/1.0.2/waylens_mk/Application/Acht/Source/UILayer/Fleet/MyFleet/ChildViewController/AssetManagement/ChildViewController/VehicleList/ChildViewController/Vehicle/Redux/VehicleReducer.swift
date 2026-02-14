//
//  VehicleReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func VehicleReducer(action: Action, state: VehicleViewControllerState?) -> VehicleViewControllerState {
        var state = state ?? VehicleViewControllerState()

        switch action {
        case ProfileActions.composingProfileInfo(let profileInfoType):
            switch profileInfoType {
            case .model(let value):
                state.vehicleProfile?.type = value
            default:
                break
            }
        case VehicleActions.updateDriverBound(let newDriver):
            if let newDriver = newDriver {
                state.vehicleProfile?.name = newDriver.name
                state.vehicleProfile?.driverID = newDriver.driverID
            } else {
                state.vehicleProfile?.name = ""
                state.vehicleProfile?.driverID = nil
            }
        case VehicleActions.updateCameraBound(let newCameraSN):
            state.vehicleProfile?.cameraSn = newCameraSN ?? ""
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case let finishedPresentingErrorAction as VehicleFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
