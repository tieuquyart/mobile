//
//  CalibrationAdjustCameraPositionViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct LoginFaceViewControllerState: ReSwift.StateType, Equatable {
    public var isCameraPositionValid: Bool = false
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: LoginFaceViewState = LoginFaceViewState(activityIndicatingState: .none)

    public init() {

    }
    
    
}

public struct LoginFaceViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState

//    public static func == (lhs: MemberViewState, rhs: MemberViewState) -> Bool {
//        return false
//    }
}
