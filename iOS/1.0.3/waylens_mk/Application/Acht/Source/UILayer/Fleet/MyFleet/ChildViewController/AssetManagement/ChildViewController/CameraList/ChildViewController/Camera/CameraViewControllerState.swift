//
//  CameraViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct CameraViewControllerState: ReSwift.StateType, Equatable {
    public var cameraProfile: CameraProfile?
    public var isShowingShortFirmwareVersion = true
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: CameraViewState = CameraViewState(activityIndicatingState: .none)

    public init(cameraProfile: CameraProfile? = nil) {
        self.cameraProfile = cameraProfile
    }
}

public struct CameraViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
