//
//  ObdWorkModeActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift
import WaylensCameraSDK

enum ObdWorkModeActions: Action {
    case doneSaving(config: WLObdWorkModeConfig)
}

struct ObdWorkModeFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
