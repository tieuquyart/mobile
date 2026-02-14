//
//  MaintenanceUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias MaintenanceUserInterfaceView = MaintenanceUserInterface & UIView

protocol MaintenanceUserInterface {
    func render(newState: MaintenanceViewControllerState)
}
