//
//  CalibrationAdjustCameraPositionReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func CalibrationAdjustCameraPositionReducer(action: Action, state: CalibrationAdjustCameraPositionViewControllerState?) -> CalibrationAdjustCameraPositionViewControllerState {
        var state = state ?? CalibrationAdjustCameraPositionViewControllerState()

    switch action {
    case CalibrationActions.judgeDmsCameraPosition(let valid):
       state.isCameraPositionValid = valid
      
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as CalibrationAdjustCameraPositionFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
