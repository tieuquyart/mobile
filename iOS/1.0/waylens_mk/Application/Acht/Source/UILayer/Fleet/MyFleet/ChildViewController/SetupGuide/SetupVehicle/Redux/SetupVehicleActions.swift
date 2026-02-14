//
//  SetupVehicleActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum SetupVehicleActions: Action {
    case completeAdding(newVehicleID: String, plateNumber: String, model: String?)
}

struct SetupVehicleFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
