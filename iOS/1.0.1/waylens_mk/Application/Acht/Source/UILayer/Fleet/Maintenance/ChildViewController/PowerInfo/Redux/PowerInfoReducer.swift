//
//  PowerInfoReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func PowerInfoReducer(action: Action, state: PowerInfoViewControllerState?) -> PowerInfoViewControllerState {
        var state = state ?? PowerInfoViewControllerState()

    switch action {
    case let generalAction as GeneralAction:
        if let camera = generalAction.value as? UnifiedCamera {
            state.camera = camera.local
        }
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as PowerInfoFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
