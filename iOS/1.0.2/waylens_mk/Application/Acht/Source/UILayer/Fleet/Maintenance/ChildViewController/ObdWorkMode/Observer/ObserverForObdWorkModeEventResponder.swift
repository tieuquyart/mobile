//
//  ObserverForObdWorkModeEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForObdWorkModeEventResponder: class {
    func received(newState: ObdWorkModeViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
