//
//  ObdWorkModeIxResponder.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import WaylensCameraSDK

protocol ObdWorkModeIxResponder: class {
    func select(mode: WLObdWorkMode)
    func select(voltage: (PartialKeyPath<WLObdWorkModeConfig>, Measurement<UnitElectricPotentialDifference>))
}
