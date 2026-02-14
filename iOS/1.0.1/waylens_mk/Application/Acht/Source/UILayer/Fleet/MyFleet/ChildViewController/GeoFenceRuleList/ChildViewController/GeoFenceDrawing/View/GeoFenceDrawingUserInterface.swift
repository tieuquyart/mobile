//
//  GeoFenceDrawingUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias GeoFenceDrawingUserInterfaceView = GeoFenceDrawingUserInterface & UIView

protocol GeoFenceDrawingUserInterface {
    func render(newState: GeoFenceDrawingViewControllerState)
}
