//
//  ObserverForSetupVehicleEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForSetupVehicleEventResponder: class {
    func received(newState: SetupVehicleViewControllerState)
    func received(newErrorMessage: ErrorMessage)
    func received(newSelectedDriver: FleetMember?)
    func received(newVehicleProfile: VehicleProfile?)
}
