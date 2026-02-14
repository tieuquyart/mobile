//
//  GeoFenceDraftBoxActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum GeoFenceDraftBoxActions: Action {

}

struct GeoFenceDraftBoxFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
