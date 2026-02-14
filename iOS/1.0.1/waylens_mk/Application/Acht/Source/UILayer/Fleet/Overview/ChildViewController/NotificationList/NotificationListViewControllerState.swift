//
//  NotificationListViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct NotificationListViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource = NotificationListDataSource(items: [], dataFilter: nil)
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: NotificationListViewState = NotificationListViewState(activityIndicatingState: .none)
    public var hasFinishedFirstLoading = false
}

public struct NotificationListViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
