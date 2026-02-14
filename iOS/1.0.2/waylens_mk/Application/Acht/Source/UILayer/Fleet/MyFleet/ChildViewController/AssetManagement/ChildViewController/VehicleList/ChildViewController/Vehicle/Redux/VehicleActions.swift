//
//  VehicleActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum VehicleActions: Action {
    case updateDriverBound(FleetMember?)
    case updateCameraBound(cameraSN: String?)
}

struct VehicleFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
