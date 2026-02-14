//
//  ObserverForAddNewCameraEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForAddNewCameraEventResponder: class {
    func received(newState: AddNewCameraViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
