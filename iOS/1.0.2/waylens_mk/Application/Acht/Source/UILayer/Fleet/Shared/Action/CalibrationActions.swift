//
//  CalibrationActions.swift
//  Fleet
//
//  Created by forkon on 2020/8/13.
//  Copyright © 2020 waylens. All rights reserved.
//

import ReSwift

public enum CalibrationActions: ReSwift.Action {
    case judgeDmsCameraPosition(valid: Bool)
    case calibrateAgain
}
