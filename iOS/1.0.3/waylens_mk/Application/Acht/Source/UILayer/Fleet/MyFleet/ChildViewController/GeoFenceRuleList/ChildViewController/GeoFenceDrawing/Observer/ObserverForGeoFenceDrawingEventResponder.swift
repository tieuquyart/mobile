//
//  ObserverForGeoFenceDrawingEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForGeoFenceDrawingEventResponder: class {
    func received(newState: GeoFenceDrawingViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
