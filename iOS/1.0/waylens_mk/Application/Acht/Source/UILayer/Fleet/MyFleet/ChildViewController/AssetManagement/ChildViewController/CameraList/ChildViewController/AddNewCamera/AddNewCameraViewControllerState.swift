//
//  AddNewCameraViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift
import WaylensCameraSDK

public struct AddNewCameraViewControllerState: ReSwift.StateType, Equatable {
    public var connectedCamera: WLCameraDevice? = nil
    public var dataSource = AddNewCameraDataSource(items: [])
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: AddNewCameraViewState = AddNewCameraViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct AddNewCameraViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
