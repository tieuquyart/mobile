//
//  GeoFenceRuleDetailActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum GeoFenceRuleDetailActions: Action {
    case loadGeoFenceRule(GeoFenceRule)
}

struct GeoFenceRuleDetailFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
