//
//  CalibrationAdjustCameraPositionReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func LoginFaceReducer(action: Action, state: LoginFaceViewControllerState?) -> LoginFaceViewControllerState {
        var state = state ?? LoginFaceViewControllerState()

    switch action {
    case CalibrationActions.judgeDmsCameraPosition(let _):
      //  state.isCameraPositionValid = valid
        state.isCameraPositionValid = true
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as LoginFaceFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
