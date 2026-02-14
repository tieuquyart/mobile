//
//  CameraListActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum CameraListActions: Action {
    case loadCameraList([CameraProfile])
}

struct CameraListFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
