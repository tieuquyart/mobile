//
//  NotificationListReducer.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

extension Reducers {

    public static func NotificationListReducer(action: Action, state: NotificationListViewControllerState?) -> NotificationListViewControllerState {
        var state = state ?? NotificationListViewControllerState()

    switch action {
    case NotificationListActions.loadNotificationList(let notifications):
        if !state.hasFinishedFirstLoading {
            state.hasFinishedFirstLoading = true
        }
        state.dataSource = NotificationListDataSource(items: notifications, dataFilter: state.dataSource.dataFilter)
    case let activityIndicatingAction as ActivityIndicatingAction:
        state.viewState.activityIndicatingState = activityIndicatingAction.state
    case DataFilterActions.applyFilter(let dataFilter):
        state.dataSource = NotificationListDataSource(items: state.dataSource.items, dataFilter: dataFilter)
    case ErrorActions.failedToProcess(let errorMessage):
        state.viewState.activityIndicatingState = .none
        state.errorsToPresent.insert(errorMessage)
    case let finishedPresentingErrorAction as NotificationListFinishedPresentingErrorAction:
        state.errorsToPresent.remove(finishedPresentingErrorAction.errorMessage)
    default:
        break
    }

        return state
    }

}
