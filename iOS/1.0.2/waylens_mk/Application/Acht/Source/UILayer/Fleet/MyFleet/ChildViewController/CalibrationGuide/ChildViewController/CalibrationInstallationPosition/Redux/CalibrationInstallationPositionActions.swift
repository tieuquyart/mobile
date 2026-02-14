//
//  CalibrationInstallationPositionActions.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

import ReSwift

enum CalibrationInstallationPositionActions: Action {
//    case xxxAlertDismissed
//    case xxxButtonTapped
//    case xxxResponse(Result)
}

struct CalibrationInstallationPositionFinishedPresentingErrorAction: FinishedPresentingErrorAction {
    let errorMessage: ErrorMessage
}
