//
//  ObdWorkModeReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import WaylensCameraSDK

extension Reducers {

    public static func ObdWorkModeReducer(action: Action, state: ObdWorkModeViewControllerState?) -> ObdWorkModeViewControllerState {
        var state = state ?? ObdWorkModeViewControllerState()

        switch action {
        case let generalAction as GeneralAction:
            if let camera = generalAction.value as? UnifiedCamera {
                state.config = camera.local?.obdWorkModeConfig
            }
        case ObdWorkModeActions.doneSaving(let config):
            state.config = config
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as ObdWorkModeFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
