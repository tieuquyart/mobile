//
//  ActivateCameraUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias ActivateCameraUserInterfaceView = ActivateCameraUserInterface & UIView

protocol ActivateCameraUserInterface {
    func render(newState: ActivateCameraViewControllerState)
}
