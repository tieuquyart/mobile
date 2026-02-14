//
//  SetupVehicleReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func SetupVehicleReducer(action: Action, state: SetupVehicleViewControllerState?) -> SetupVehicleViewControllerState {
        var state = state ?? SetupVehicleViewControllerState()

        if state.viewState.activityIndicatingState.isSuccess {
            state.viewState.activityIndicatingState = .none
        }

        switch action {
        case SetupVehicleActions.completeAdding(let newvehicleID, _, _):
            state.vehicleProfile.vehicleID = newvehicleID
        case CameraListActions.loadCameraList(let items):
            let availableItems = items.filter{!$0.isBind}
            state.cameras = availableItems
        case SelectorActions.select(let indexPath):
            state.selectedCamera = state.cameras[indexPath.row]
        case SelectorActions.finish(let selectedItem):
            switch selectedItem {
            case let selectedDriver as FleetMember:
                if selectedDriver.driverID == state.selectedDriver?.driverID {
                    state.selectedDriver = nil
                } else {
                    state.selectedDriver = selectedDriver
                }
            case let selectedVehicle as VehicleProfile:
                state.vehicleProfile = selectedVehicle

                if let driverID = selectedVehicle.driverID {
                    state.selectedDriver = FleetMember(
                        name: selectedVehicle.name ?? "",
                        roles: .driver,
                        email: nil,
                        phoneNumber: nil,
                        isVerified: false,
                        isOwner: false,
                        driverID: driverID
                    )
                }
            default:
                break
            }
        case ProfileActions.composingProfileInfo(let profileInfo):
            switch profileInfo {
            case .model(let value):
                state.vehicleProfile.type = value
            case .plateNumber(let value):
                state.vehicleProfile.plateNo = value
            default:
                break
            }
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case VehicleActions.updateDriverBound(_):
            state.hasBoundDriver = true
        case VehicleActions.updateCameraBound(_):
            state.hasBoundCamera = true
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case BindCameraActions.failToBind(_):
            state.viewState.activityIndicatingState = .none
            state.bindCameraFailed = true
        case BindDriverActions.failToBind(_):
            state.viewState.activityIndicatingState = .none
            state.bindDriverFailed = true
        case let finishedPresentingErrorAction as SetupVehicleFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
