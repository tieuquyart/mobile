//
//  TriggeringVehicleSelectorReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func TriggeringVehicleSelectorReducer(action: Action, state: TriggeringVehicleSelectorViewControllerState?) -> TriggeringVehicleSelectorViewControllerState {
        var state = state ?? TriggeringVehicleSelectorViewControllerState()

        switch action {
        case VehicleListActions.loadVehicleList(let vehicles):
            state.loadedState = .loaded(state: vehicles)
        case SelectorActions.select(let indexPath):
            if case .loaded(let vehicles) = state.loadedState, let vehicleId = vehicles[indexPath.row].vehicleID {
                if state.rule.vehicleList == nil {
                    state.rule.vehicleList = []
                }

                if  state.rule.vehicleList?.contains(vehicleId) == true {
                    state.rule.vehicleList?.removeAll(where: {$0 == vehicleId})
                }
                else {
                    state.rule.vehicleList?.append(vehicleId)
                }
            }
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as TriggeringVehicleSelectorFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
