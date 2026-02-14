//
//  GeoFenceActions.swift
//  Fleet
//
//  Created by forkon on 2020/6/12.
//  Copyright © 2020 waylens. All rights reserved.
//

import ReSwift

public enum GeoFenceActions: ReSwift.Action {
    case beginLoadingGeoFence(GeoFenceId)
    case loadedGeoFence(GeoFence)
    case failedToLoadGeoFence(GeoFenceId)
}
