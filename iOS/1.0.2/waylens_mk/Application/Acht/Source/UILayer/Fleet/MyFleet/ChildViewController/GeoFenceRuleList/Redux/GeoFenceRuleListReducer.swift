//
//  GeoFenceRuleListReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func GeoFenceRuleListReducer(action: Action, state: GeoFenceRuleListViewControllerState?) -> GeoFenceRuleListViewControllerState {
        var state = state ?? GeoFenceRuleListViewControllerState()

    switch action {
    case GeoFenceRuleListActions.loadGeoFenceRuleList(let rules):
        state.loadedState = .loaded(state: rules.sorted{$0.createTime > $1.createTime})
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as GeoFenceRuleListFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
