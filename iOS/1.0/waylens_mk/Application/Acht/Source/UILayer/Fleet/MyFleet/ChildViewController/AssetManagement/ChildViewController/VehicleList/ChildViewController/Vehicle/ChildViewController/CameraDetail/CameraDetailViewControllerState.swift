//
//  CameraDetailViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct CameraDetailViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource = CameraDetailDataSource(items: [])
    public var cameraInfo: CameraInfo?
    public var isShowingShortFirmwareVersion = true
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: CameraDetailViewState = CameraDetailViewState(activityIndicatingState: .none)

    public init(cameraInfo: CameraInfo? = nil) {
        self.cameraInfo = cameraInfo
    }
}

public struct CameraDetailViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
