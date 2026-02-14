//
//  ActivateCameraViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct ActivateCameraViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource: ActivateCameraDataSource
    public var camera: CameraProfile?
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: ActivateCameraViewState = ActivateCameraViewState(activityIndicatingState: .none)

    public init(camera: CameraProfile?) {
        self.camera = camera
        self.dataSource = ActivateCameraDataSource(camera: camera)
    }
}

public struct ActivateCameraViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
