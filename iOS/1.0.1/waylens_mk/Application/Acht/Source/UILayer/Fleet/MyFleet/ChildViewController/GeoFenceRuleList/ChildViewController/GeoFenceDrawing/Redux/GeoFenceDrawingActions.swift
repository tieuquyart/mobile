//
//  GeoFenceDrawingActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum GeoFenceDrawingActions: Action {
    case composeGeoFence(composedData: Any)
    case cleanGeoFence
    case savedGeoFence(geoFenceId: GeoFenceId)
}

struct GeoFenceDrawingFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
