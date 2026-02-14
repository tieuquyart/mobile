//
//  AddNewGeoFenceActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum AddNewGeoFenceActions: Action {
    case editedGeoFenceRule(_ newRule: GeoFenceRuleForEdit)
}

struct AddNewGeoFenceFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
