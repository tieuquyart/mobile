//
//  GeoFenceDraftBoxUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias GeoFenceDraftBoxUserInterfaceView = GeoFenceDraftBoxUserInterface & UIView

protocol GeoFenceDraftBoxUserInterface {
    func render(newState: GeoFenceDraftBoxViewControllerState)
}
