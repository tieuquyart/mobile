//
//  CameraListViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct CameraListViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource = CameraListDataSource(cameras: [])
    public var viewState: CameraListViewState = CameraListViewState(activityIndicatingState: .none)
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var hasFinishedFirstLoading = false

    public init() {

    }
}

public struct CameraListViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
