//
//  VehicleListActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum VehicleListActions: Action {
    case loadVehicleList([VehicleProfile])
    case selectVehicle(index: Int)
}

struct VehicleListFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
