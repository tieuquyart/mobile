//
//  ObserverForCameraEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForCameraEventResponder: class {
    func received(newState: CameraViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
