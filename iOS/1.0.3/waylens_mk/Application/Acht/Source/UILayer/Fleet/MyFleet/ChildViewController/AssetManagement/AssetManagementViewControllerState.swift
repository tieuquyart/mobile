//
//  AssetManagementViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct AssetManagementViewControllerState: ReSwift.StateType, Equatable {
    public var viewState: AssetManagementViewState = AssetManagementViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct AssetManagementViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
