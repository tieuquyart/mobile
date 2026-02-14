//
//  ObserverForCalibrationVehicleInfoEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForCalibrationVehicleInfoEventResponder: class {
    func received(newState: CalibrationVehicleInfoViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
