//
//  VehicleSelectorUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias VehicleSelectorUserInterfaceView = VehicleSelectorUserInterface & UIView

protocol VehicleSelectorUserInterface {
    func render(newState: VehicleSelectorViewControllerState)
}
