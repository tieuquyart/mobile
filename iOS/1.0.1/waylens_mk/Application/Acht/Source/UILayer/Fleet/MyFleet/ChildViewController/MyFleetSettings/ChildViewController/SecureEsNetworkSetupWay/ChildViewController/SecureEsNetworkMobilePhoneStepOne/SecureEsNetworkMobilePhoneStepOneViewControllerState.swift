//
//  SecureEsNetworkMobilePhoneStepOneViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct SecureEsNetworkMobilePhoneStepOneViewControllerState: ReSwift.StateType, Equatable {
    public var loadedState: LoadedState<[String]> = .notLoaded
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: SecureEsNetworkMobilePhoneStepOneViewState = SecureEsNetworkMobilePhoneStepOneViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct SecureEsNetworkMobilePhoneStepOneViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState

//    public static func == (lhs: MemberViewState, rhs: MemberViewState) -> Bool {
//        return false
//    }
}
