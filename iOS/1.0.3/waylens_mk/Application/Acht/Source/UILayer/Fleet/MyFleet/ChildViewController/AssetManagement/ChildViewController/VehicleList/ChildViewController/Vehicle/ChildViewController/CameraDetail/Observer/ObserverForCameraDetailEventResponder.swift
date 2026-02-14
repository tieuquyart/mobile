//
//  ObserverForCameraDetailEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForCameraDetailEventResponder: class {
    func received(newState: CameraDetailViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
