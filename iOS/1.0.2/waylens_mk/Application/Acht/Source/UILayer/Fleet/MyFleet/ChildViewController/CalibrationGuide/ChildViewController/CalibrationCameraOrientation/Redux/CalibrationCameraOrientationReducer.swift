//
//  CalibrationCameraOrientationReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func CalibrationCameraOrientationReducer(action: Action, state: CalibrationCameraOrientationViewControllerState?) -> CalibrationCameraOrientationViewControllerState {
        var state = state ?? CalibrationCameraOrientationViewControllerState()

    switch action {
//    case CalibrationCameraOrientationActions:
//    <#code#>
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as CalibrationCameraOrientationFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
