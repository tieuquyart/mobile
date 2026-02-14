//
//  ObserverForCalibrationAdjustCameraPositionEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForLoginFaceViewEventResponder: class {
    func received(newState: LoginFaceViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
