//
//  CameraListReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func CameraListReducer(action: Action, state: CameraListViewControllerState?) -> CameraListViewControllerState {
        var state = state ?? CameraListViewControllerState()

        switch action {
        case CameraListActions.loadCameraList(let cameras):
            if !state.hasFinishedFirstLoading {
                state.hasFinishedFirstLoading = true
            }
            state.dataSource = CameraListDataSource(cameras: cameras)
        case let activityIndicatingAction as ActivityIndicatingAction:
            state.viewState.activityIndicatingState = activityIndicatingAction.state
        case let finishedPresentingErrorAction as CameraListFinishedPresentingErrorAction:
            state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
        default:
            break
        }

        return state
    }

}
