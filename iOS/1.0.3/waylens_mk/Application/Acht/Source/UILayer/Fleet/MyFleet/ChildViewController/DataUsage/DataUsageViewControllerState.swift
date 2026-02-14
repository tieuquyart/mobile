//
//  DataUsageViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct DataUsageViewControllerState: ReSwift.StateType, Equatable {
    public var dataSource: DataUsageDataSource = DataUsageDataSource(thisMonthBillingData: nil, historyBillingDataArray: [])
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var viewState: DataUsageViewState = DataUsageViewState(activityIndicatingState: .none)
    public var hasFinishedFirstLoading = false

    public init() {

    }
}

public struct DataUsageViewState: Equatable {
    var activityIndicatingState: ActivityIndicatingState
}

protocol LoadableDataSource {
    var hasFinishedFirstLoading: Bool { set get }
}

private var hasFinishedFirstLoadingKey: UInt8 = 8

extension LoadableDataSource {

    var hasFinishedFirstLoading: Bool {
        set {
            objc_setAssociatedObject(self, &hasFinishedFirstLoadingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &hasFinishedFirstLoadingKey) as? Bool) ?? false
        }
    }

}
