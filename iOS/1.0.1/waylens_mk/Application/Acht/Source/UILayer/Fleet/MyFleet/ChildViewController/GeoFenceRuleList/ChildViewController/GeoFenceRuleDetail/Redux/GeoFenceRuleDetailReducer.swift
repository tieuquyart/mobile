//
//  GeoFenceRuleDetailReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func GeoFenceRuleDetailReducer(action: Action, state: GeoFenceRuleDetailViewControllerState?) -> GeoFenceRuleDetailViewControllerState {
        var state = state ?? GeoFenceRuleDetailViewControllerState()

        switch action {
        case GeoFenceActions.loadedGeoFence(let geoFence):
            state.fence = geoFence
        case GeoFenceRuleDetailActions.loadGeoFenceRule(let geoFenceRule):
            state.rule = geoFenceRule
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as GeoFenceRuleDetailFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
