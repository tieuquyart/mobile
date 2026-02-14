//
//  GeoFenceDrawingIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol GeoFenceDrawingIxResponder: class {
    func composeGeoFence(with data: Any)
    func cleanGeoFence()
    func doneComposingGeoFence()
    func nextStep()
    func showLocationPicker()
    func editRange()
}
