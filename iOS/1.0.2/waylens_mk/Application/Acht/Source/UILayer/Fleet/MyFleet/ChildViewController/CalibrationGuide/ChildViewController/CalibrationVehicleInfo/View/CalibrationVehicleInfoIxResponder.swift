//
//  CalibrationVehicleInfoIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol CalibrationVehicleInfoIxResponder: class {
    func select(indexPath: IndexPath)
    func nextStep(with selectedItems: [CalibrationVehicleInfoViewState.Element])
}
