//
//  GeoFenceRuleTypeAndScopeUserInterface.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

typealias GeoFenceRuleTypeAndScopeUserInterfaceView = GeoFenceRuleTypeAndScopeUserInterface & UIView

protocol GeoFenceRuleTypeAndScopeUserInterface {
    func render(newState: GeoFenceRuleTypeAndScopeViewControllerState)
}
