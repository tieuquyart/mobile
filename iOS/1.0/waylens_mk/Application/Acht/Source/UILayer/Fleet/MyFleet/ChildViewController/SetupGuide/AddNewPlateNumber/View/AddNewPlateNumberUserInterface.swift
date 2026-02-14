//
//  AddNewPlateNumberUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias AddNewPlateNumberUserInterfaceView = AddNewPlateNumberUserInterface & UIView

protocol AddNewPlateNumberUserInterface {
    var plateNumber: String? { get }
    func render(newState: AddNewPlateNumberViewControllerState)
}
