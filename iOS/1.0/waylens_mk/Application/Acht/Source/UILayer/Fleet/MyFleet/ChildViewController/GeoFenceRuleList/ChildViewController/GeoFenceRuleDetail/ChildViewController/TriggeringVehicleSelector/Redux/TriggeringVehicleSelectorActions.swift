//
//  TriggeringVehicleSelectorActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum TriggeringVehicleSelectorActions: Action {

}

struct TriggeringVehicleSelectorFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
