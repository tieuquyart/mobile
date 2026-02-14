//
//  MaintenanceReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import WaylensCameraSDK

extension Reducers {
    
    public static func MaintenanceReducer(action: Action, state: MaintenanceViewControllerState?) -> MaintenanceViewControllerState {
        var state = state ?? MaintenanceViewControllerState()
        
        switch action {
        case let generalAction as GeneralAction:
            if let camera = generalAction.value as? UnifiedCamera {
                state.hasDmsCamera = camera.local?.hasDmsCamera ?? false
                state.obdWorkModeConfig = camera.local?.obdWorkModeConfig
                state.adasConfig = camera.local?.adasConfig
            }
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as MaintenanceFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }
        
        return state
    }
    
}
