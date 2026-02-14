//
//  RecordConfigReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import WaylensCameraSDK

extension Reducers {

    public static func RecordConfigReducer(action: Action, state: RecordConfigViewControllerState?) -> RecordConfigViewControllerState {
        var state = state ?? RecordConfigViewControllerState()

    switch action {
    case RecordConfigActions.updateRecordConfigList(let recordConfigList):
        state.items = recordConfigList
    case RecordConfigActions.updateRecordConfig(let recordConfig):
        state.selectedItem = recordConfig
        state.willSelectedItem = nil
    case RecordConfigActions.willSelectRecordConfig(let recordConfig):
        state.willSelectedItem = state.items.first(where: {$0.name == recordConfig})
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as RecordConfigFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
