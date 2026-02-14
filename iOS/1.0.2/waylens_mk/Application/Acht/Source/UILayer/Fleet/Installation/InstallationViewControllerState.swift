//
//  InstallationViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct InstallationViewControllerState: ReSwift.StateType, Equatable {
    public var loadedState: LoadedState<[String]> = .notLoaded
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: InstallationViewState = InstallationViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct InstallationViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
    
//    public static func == (lhs: MemberViewState, rhs: MemberViewState) -> Bool {
//        return false
//    }
}
