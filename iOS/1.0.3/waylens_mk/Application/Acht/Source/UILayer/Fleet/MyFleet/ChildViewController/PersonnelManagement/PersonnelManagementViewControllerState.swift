//
//  PersonnelManagementViewControllerState.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import RxSwift

public struct PersonnelManagementViewControllerState: ReSwift.StateType, Equatable {
    public var members: [MemberProfile] = []
    public var viewState: VehicleViewState = VehicleViewState(activityIndicatingState: .none)
    public internal(set) var errorsToPresent: Set<ErrorMessage> = []
    public var hasFinishedFirstLoading = false
}
