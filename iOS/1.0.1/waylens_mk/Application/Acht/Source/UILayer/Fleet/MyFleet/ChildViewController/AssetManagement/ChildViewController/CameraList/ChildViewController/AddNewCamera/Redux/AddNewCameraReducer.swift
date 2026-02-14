//
//  AddNewCameraReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import WaylensCameraSDK

extension Reducers {

    public static func AddNewCameraReducer(action: Action, state: AddNewCameraViewControllerState?) -> AddNewCameraViewControllerState {
        var state = state ?? AddNewCameraViewControllerState()

        switch action {
        case let generalAction as GeneralAction:
            state.connectedCamera = (generalAction.value as? WLCameraDevice)
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as AddNewCameraFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
