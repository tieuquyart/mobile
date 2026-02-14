//
//  ObserverForDataUsageEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForDataUsageEventResponder: class {
    func received(newState: DataUsageViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
