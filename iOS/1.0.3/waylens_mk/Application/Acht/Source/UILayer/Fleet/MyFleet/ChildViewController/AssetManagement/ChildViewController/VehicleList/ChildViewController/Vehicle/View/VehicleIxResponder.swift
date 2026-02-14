//
//  VehicleIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol VehicleIxResponder: class {
    func unbindCamera()
    func removeThisVehicle()
    func showDriverSelectionViewController()
    func showModelEditViewController()
    func showCameraDetailViewController()
    func showCameraBindingViewController()
}
