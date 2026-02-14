//
//  BindCameraReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func BindCameraReducer(action: Action, state: BindCameraViewControllerState?) -> BindCameraViewControllerState {
        var state = state ?? BindCameraViewControllerState()

    switch action {
    case CameraListActions.loadCameraList(let items):
        let availableItems = items.filter{!$0.isBind}
        state.dataSource = BindCameraDataSource(items: availableItems)

        if !state.hasFinishedFirstLoading {
            state.hasFinishedFirstLoading = true
        }
    case SelectorActions.select(let indexPath):
        state.dataSource = BindCameraDataSource(items: state.dataSource.provider.items.first ?? [], selectedIndexPath: indexPath)
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case BindCameraActions.failToBind(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as BindCameraFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
