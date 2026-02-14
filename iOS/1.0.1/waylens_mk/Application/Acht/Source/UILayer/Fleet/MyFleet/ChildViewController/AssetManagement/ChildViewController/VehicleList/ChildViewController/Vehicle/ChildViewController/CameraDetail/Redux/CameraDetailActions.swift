//
//  CameraDetailActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum CameraDetailActions: Action {
    case loadCameraInfo(CameraInfo?)
    case toggleFirmwareVersion
}

struct CameraDetailFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
