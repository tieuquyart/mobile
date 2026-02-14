//
//  AddNewVehicleActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum AddNewVehicleActions: Action {
    case completeAdding(newVehicleID: String, plateNumber: String, model: String?)
}

struct AddNewVehicleFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
