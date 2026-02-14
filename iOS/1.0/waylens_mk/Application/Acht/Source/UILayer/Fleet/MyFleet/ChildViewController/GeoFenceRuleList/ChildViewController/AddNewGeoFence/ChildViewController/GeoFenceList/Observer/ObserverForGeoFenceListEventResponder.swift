//
//  ObserverForGeoFenceListEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForGeoFenceListEventResponder: class {
    func received(newState: GeoFenceListViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
