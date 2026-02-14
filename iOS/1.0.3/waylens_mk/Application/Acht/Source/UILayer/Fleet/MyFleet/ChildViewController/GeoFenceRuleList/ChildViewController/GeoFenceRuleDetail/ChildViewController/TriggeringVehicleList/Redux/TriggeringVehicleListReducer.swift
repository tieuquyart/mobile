//
//  TriggeringVehicleListReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func TriggeringVehicleListReducer(action: Action, state: TriggeringVehicleListViewControllerState?) -> TriggeringVehicleListViewControllerState {
        var state = state ?? TriggeringVehicleListViewControllerState()

    switch action {
    case GeoFenceRuleDetailActions.loadGeoFenceRule(let rule):
        state.rule = GeoFenceRuleForEdit(rule: rule)
    case VehicleListActions.loadVehicleList(let vehicles):
        state.loadedState = .loaded(state: vehicles)
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as TriggeringVehicleListFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
