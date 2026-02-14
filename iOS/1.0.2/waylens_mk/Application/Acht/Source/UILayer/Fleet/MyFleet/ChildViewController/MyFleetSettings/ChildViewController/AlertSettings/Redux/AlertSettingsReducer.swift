//
//  AlertSettingsReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func AlertSettingsReducer(action: Action, state: AlertSettingsViewControllerState?) -> AlertSettingsViewControllerState {
        var state = state ?? AlertSettingsViewControllerState()

        switch action {
        case AlertSettingsActions.loadAlertSettings(let settings):
            if !state.hasFinishedFirstLoading {
                state.hasFinishedFirstLoading = true
            }

            state.disabledAlertSettings = Set(settings)
        case AlertSettingsActions.toggleAlertSettings(let setting, let isOn):
            if isOn {
                state.disabledAlertSettings = state.disabledAlertSettings.subtracting(setting)
            } else {
                state.disabledAlertSettings = state.disabledAlertSettings.union(setting)
            }
            break
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as AlertSettingsFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }
        return state
    }

}
