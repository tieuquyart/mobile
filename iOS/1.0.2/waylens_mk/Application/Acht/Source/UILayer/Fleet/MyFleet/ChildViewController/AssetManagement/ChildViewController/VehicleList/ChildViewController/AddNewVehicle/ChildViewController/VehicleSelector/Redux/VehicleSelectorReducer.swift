//
//  VehicleSelectorReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func VehicleSelectorReducer(action: Action, state: VehicleSelectorViewControllerState?) -> VehicleSelectorViewControllerState {
        var state = state ?? VehicleSelectorViewControllerState()

        if state.viewState.activityIndicatingState.isSuccess {
            state.viewState.activityIndicatingState = .none
        }

        switch action {
        case VehicleListActions.loadVehicleList(let vehicles):
            let items = vehicles.filter{$0.cameraSn.isEmpty}
            state.dataSource = VehicleSelectorDataSource(items: items)

            if !state.hasFinishedFirstLoading {
                state.hasFinishedFirstLoading = true
            }
        case SelectorActions.select(let indexPath):
            state.dataSource = VehicleSelectorDataSource(items: state.dataSource.provider.items.first ?? [], selectedIndexPath: indexPath)
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as VehicleSelectorFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
