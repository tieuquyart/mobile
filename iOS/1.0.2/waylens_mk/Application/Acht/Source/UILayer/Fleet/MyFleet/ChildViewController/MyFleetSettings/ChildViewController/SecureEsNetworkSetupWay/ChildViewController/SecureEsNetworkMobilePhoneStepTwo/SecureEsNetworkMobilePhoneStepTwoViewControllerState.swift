//
//  SecureEsNetworkMobilePhoneStepTwoViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct SecureEsNetworkMobilePhoneStepTwoViewControllerState: ReSwift.StateType, Equatable {
    public var loadedState: LoadedState<[String]> = .notLoaded
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: SecureEsNetworkMobilePhoneStepTwoViewState = SecureEsNetworkMobilePhoneStepTwoViewState(activityIndicatingState: .none)

    public init() {

    }
}

public struct SecureEsNetworkMobilePhoneStepTwoViewState: Equatable {
    private(set) var lastUpdateDate: Date = Date()
    var activityIndicatingState: ActivityIndicatingState {
        didSet {
            lastUpdateDate = Date()
        }
    }

}
