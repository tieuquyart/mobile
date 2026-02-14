//
//  ObserverForVehicleListEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForVehicleListEventResponder: class {
    func received(newState: VehicleListViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
