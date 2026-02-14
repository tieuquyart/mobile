//
//  GeoFenceRuleTypeAndScopeIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol GeoFenceRuleTypeAndScopeIxResponder: class {
    func select(indexPath: IndexPath)
    func changeRule(using ruleReducer: @escaping GeoFenceRuleReducer)
    func saveGeoFenceRule()
    func nextStep()
}
