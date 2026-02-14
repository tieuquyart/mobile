//
//  AddNewCameraUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias AddNewCameraUserInterfaceView = AddNewCameraUserInterface & UIView

protocol AddNewCameraUserInterface {
    var sn: String? { get }
    var password: String? { get }
    func render(newState: AddNewCameraViewControllerState)
}
