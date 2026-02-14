//
//  GeoFenceListIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol GeoFenceListIxResponder: class {
    func select(indexPath: IndexPath)
    func requestGeoFenceShapeDetail(with fenceId: GeoFenceId)
    func delete(item: GeoFence)
}
