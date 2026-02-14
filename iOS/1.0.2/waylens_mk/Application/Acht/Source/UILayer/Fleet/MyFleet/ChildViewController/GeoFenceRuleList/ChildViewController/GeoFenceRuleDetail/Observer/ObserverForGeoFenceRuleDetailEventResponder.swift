//
//  ObserverForGeoFenceRuleDetailEventResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol ObserverForGeoFenceRuleDetailEventResponder: class {
    func received(newState: GeoFenceRuleDetailViewControllerState)
    func received(newErrorMessage: ErrorMessage)
}
