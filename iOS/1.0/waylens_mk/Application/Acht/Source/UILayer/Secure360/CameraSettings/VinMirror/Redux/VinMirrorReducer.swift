//
//  VinMirrorReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func VinMirrorReducer(action: Action, state: VinMirrorViewControllerState?) -> VinMirrorViewControllerState {
        var state = state ?? VinMirrorViewControllerState()

    switch action {
    case VinMirrorActions.updateVinMirrors(let vinMirrors):
        state.items = vinMirrors
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as VinMirrorFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
