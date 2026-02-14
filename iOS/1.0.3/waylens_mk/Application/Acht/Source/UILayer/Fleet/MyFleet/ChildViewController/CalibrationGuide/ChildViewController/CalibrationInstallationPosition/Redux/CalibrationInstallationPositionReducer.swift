//
//  CalibrationInstallationPositionReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func CalibrationInstallationPositionReducer(action: Action, state: CalibrationInstallationPositionViewControllerState?) -> CalibrationInstallationPositionViewControllerState {
        var state = state ?? CalibrationInstallationPositionViewControllerState()

    switch action {
//    case CalibrationInstallationPositionActions:
//    <#code#>
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as CalibrationInstallationPositionFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
