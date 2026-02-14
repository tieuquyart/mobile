//
//  PowerInfoViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift
import WaylensCameraSDK

public struct PowerInfoViewControllerState: ReSwift.StateType, Equatable {
    public var camera: WLCameraDevice? = nil
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: PowerInfoViewState = PowerInfoViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct PowerInfoViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
