//
//  CameraReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func CameraReducer(action: Action, state: CameraViewControllerState?) -> CameraViewControllerState {
        var state = state ?? CameraViewControllerState()

        switch action {
        case CameraActions.activateCamera:
            state.cameraProfile?.simState = .activated
        case CameraDetailActions.toggleFirmwareVersion:
            state.isShowingShortFirmwareVersion = !state.isShowingShortFirmwareVersion
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as CameraFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
