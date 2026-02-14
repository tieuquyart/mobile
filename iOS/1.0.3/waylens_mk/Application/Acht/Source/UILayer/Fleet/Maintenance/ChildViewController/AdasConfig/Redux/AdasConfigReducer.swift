//
//  AdasConfigReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import WaylensCameraSDK

extension Reducers {
    
    public static func AdasConfigReducer(action: Action, state: AdasConfigViewControllerState?) -> AdasConfigViewControllerState {
        var state = state ?? AdasConfigViewControllerState()
        
        switch action {
        case let generalAction as GeneralAction:
            if let camera = generalAction.value as? UnifiedCamera {
                state.adasConfig = camera.local?.adasConfig
            }
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case ErrorActions.failedToProcess(let errorMessage):
            state.viewState.activityIndicatingState = .none
            state.errorsToPresent.insert(errorMessage)
        case let finishedPresentingErrorAction as AdasConfigFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }
        
        return state
    }
    
}
