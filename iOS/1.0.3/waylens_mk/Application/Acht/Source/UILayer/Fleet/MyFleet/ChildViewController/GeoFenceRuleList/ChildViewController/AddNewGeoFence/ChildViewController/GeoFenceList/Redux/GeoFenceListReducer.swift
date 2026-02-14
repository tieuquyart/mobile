//
//  GeoFenceListReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func GeoFenceListReducer(action: Action, state: GeoFenceListViewControllerState?) -> GeoFenceListViewControllerState {
        var state = state ?? GeoFenceListViewControllerState()

    switch action {
    case GeoFenceListActions.loadGeoFences(let geoFences):
        if case .loaded(let oldGeoFences) = state.loadedState {
            var geoFences = geoFences

            oldGeoFences.forEach { (geoFence) in
                if let i = geoFences.firstIndex(where: {$0.fenceID == geoFence.fenceID}) {
                    geoFences[i].shape = geoFence.shape
                }
            }

            state.loadedState = .loaded(state: geoFences.sorted{$0.createTime > $1.createTime})
        }
        else {
            state.loadedState = .loaded(state: geoFences.sorted{$0.createTime > $1.createTime})
        }
    case GeoFenceActions.loadedGeoFence(let geoFence):
        if case .loaded(let geoFenceListItems) = state.loadedState {
            var geoFences = geoFenceListItems

            if let i = geoFences.firstIndex(where: {$0.fenceID == geoFence.fenceID}), geoFences[i].shape == .unknown {
                geoFences[i].shape = geoFence.shape
                state.loadedState = .loaded(state: geoFences.sorted{$0.createTime > $1.createTime})
            }
        }
        state.loadingGeoFences.remove(geoFence.fenceID)
    case GeoFenceActions.beginLoadingGeoFence(let geoFenceId):
        state.loadingGeoFences.insert(geoFenceId)
    case GeoFenceActions.failedToLoadGeoFence(let geoFenceId):
        state.loadingGeoFences.remove(geoFenceId)
    case GeoFenceListActions.deleteGeoFence(let fenceId):
        if case .loaded(let geoFences) = state.loadedState {
            var geoFences = geoFences

            if let i = geoFences.firstIndex(where: {$0.fenceID == fenceId}) {
                geoFences.remove(at: i)
                state.loadedState = .loaded(state: geoFences.sorted{$0.createTime > $1.createTime})
            }
        }
    case SelectorActions.select(let indexPath):
        if case .loaded(let geoFences) = state.loadedState {
            let fence = geoFences[indexPath.row]
            state.rule.fenceID = fence.fenceID

            if state.type == .unbind { // using as draft box
                state.rule.name = fence.name
            }
        }
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as GeoFenceListFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
