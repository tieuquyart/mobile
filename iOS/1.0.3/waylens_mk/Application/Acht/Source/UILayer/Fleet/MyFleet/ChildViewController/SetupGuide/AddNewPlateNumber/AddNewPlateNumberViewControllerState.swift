//
//  AddNewPlateNumberViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct AddNewPlateNumberViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource = AddNewPlateNumberDataSource(items: [])
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: AddNewPlateNumberViewState = AddNewPlateNumberViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct AddNewPlateNumberViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
