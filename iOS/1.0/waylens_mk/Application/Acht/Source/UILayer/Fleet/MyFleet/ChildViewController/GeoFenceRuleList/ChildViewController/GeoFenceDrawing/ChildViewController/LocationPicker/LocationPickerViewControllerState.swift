//
//  LocationPickerViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct LocationPickerViewControllerState: ReSwift.StateType, Equatable {
    public internal(set) var searchResults: [NamedLocation] = []
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: LocationPickerViewState = LocationPickerViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct LocationPickerViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
