//
//  VinMirrorViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public enum VinMirror: String, CaseIterable {
    case normal
    case horz_vert

    func inverted() -> Self {
        if self == .normal {
            return .horz_vert
        }
        else {
            return .normal
        }
    }
}

public struct VinMirrorViewControllerState: ReSwift.StateType, Equatable {
    public var items: [VinMirror] = []
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: VinMirrorViewState = VinMirrorViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct VinMirrorViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
