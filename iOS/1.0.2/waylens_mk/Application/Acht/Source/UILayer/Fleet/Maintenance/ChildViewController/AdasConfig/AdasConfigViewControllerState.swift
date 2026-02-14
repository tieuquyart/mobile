//
//  AdasConfigViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift
import WaylensCameraSDK

public struct AdasConfigViewControllerState: ReSwift.StateType, Equatable {
    public var adasConfig: WLAdasConfig? = nil
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: AdasConfigViewState = AdasConfigViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct AdasConfigViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState

//    public static func == (lhs: MemberViewState, rhs: MemberViewState) -> Bool {
//        return false
//    }
}
