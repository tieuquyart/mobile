//
//  ObserverForAdasConfigEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForAdasConfigEventResponder: class {
    func received(newState: AdasConfigViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
