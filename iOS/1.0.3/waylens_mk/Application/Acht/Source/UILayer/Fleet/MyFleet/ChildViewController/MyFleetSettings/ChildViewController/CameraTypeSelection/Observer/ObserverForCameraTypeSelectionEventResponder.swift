//
//  ObserverForCameraTypeSelectionEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForCameraTypeSelectionEventResponder: class {
    func received(newState: CameraTypeSelectionViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
