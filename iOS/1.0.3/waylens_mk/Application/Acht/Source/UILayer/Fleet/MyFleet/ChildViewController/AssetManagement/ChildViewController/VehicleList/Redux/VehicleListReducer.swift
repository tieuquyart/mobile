//
//  VehicleListReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func VehicleListReducer(action: Action, state: VehicleListViewControllerState?) -> VehicleListViewControllerState {
        var state = state ?? VehicleListViewControllerState()

        switch action {
        case VehicleListActions.loadVehicleList(let vehicles):
            if !state.hasFinishedFirstLoading {
                state.hasFinishedFirstLoading = true
            }
            state.dataSource = VehicleListDataSource(vehicles: vehicles)
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case let finishedPresentingErrorAction as VehicleListFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }
        return state
    }

}
