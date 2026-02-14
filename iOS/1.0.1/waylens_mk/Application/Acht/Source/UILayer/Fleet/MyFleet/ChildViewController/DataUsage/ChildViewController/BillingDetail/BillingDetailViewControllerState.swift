//
//  BillingDetailViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct BillingDetailViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource: BillingDetailDataSource
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: BillingDetailViewState = BillingDetailViewState(activityIndicatingState: .none)

    public init(billingData: BillingData? = nil) {
        self.dataSource = BillingDetailDataSource(billingData: billingData)
    }
}

public struct BillingDetailViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}
