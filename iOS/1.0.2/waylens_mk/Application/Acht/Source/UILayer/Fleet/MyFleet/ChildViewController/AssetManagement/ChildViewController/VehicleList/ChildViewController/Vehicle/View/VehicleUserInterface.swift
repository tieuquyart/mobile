//
//  VehicleUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias VehicleUserInterfaceView = VehicleUserInterface & UIView

protocol VehicleUserInterface {
    func clearsSelection()
    func render(newState: VehicleViewControllerState)
}
