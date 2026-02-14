//
//  ObserverForActivateCameraEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForActivateCameraEventResponder: class {
    func received(newState: ActivateCameraViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
