//
//  GeoFenceRuleListActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum GeoFenceRuleListActions: Action {
    case loadGeoFenceRuleList([GeoFenceRule])
}

struct GeoFenceRuleListFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
