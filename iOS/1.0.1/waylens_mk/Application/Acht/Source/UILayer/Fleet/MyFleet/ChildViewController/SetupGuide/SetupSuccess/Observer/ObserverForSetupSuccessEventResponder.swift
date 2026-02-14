//
//  ObserverForSetupSuccessEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForSetupSuccessEventResponder: class {
    func received(newState: SetupSuccessViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
