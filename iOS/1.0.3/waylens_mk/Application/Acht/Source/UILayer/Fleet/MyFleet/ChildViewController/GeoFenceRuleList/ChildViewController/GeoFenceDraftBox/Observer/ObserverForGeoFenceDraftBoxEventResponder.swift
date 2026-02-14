//
//  ObserverForGeoFenceDraftBoxEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForGeoFenceDraftBoxEventResponder: class {
    func received(newState: GeoFenceDraftBoxViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
