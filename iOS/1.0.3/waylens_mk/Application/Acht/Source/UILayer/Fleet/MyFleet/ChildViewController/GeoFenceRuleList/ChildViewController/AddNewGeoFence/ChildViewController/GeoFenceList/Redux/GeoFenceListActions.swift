//
//  GeoFenceListActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum GeoFenceListActions: Action {
    case loadGeoFences([GeoFenceListItem])
    case deleteGeoFence(GeoFenceId)
}

struct GeoFenceListFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
