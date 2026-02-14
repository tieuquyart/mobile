//
//  AddNewVehicleIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol AddNewVehicleIxResponder: class {
    func selectCamera(at indexPath: IndexPath)
    func addVehicle()
    func gotoPlateNumberComposing()
    func gotoVehicleModelComposing()
    func gotoDriverSelector()
    func gotoAddNewCamera()
//    func addVehicle(with plateNumber: String?, vehicleModel: String?)
}
