//
//  ObserverForMaintenanceEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForMaintenanceEventResponder: class {
    func received(newState: MaintenanceViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
